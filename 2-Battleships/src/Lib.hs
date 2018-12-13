module Lib
    ( getTheMovesRequest,
    sendPostRequest,
    BattleshipsMsg (..),
    BattleshipsTable (..),
    addMyMove,
    moveToBEncode,
    checkAllBsMMoves,
    checkMeAlive,
    getEnemyPlayerId,
    selectOnlyPlayerMoves,
    fillIfLast,
    checkMyWin,
    parseAllMoves
    ) where

import Network.HTTP
import Network.HTTP.Headers
import Network.Stream (Result)
import Data.Maybe
import Data.Either
import Data.Char
import qualified Data.Map.Strict as Map
import Data.Map (Map())
import Control.Exception

import Data.BEncode
import Data.BEncode.Parser
import Data.BEncode.Lexer
import qualified Data.ByteString.Lazy as Bsl
import qualified Data.ByteString.Char8 as Bs

data BattleshipsMsg = BattleshipsMsg {
    bsMcoord :: Maybe (Char, Int),
    bsMresult :: Maybe Bool,
    bsMprev :: Maybe BattleshipsMsg
} deriving Show

data BattleshipsTable = BattleshipsTable {
    bsTentries :: [(Char, Int)]
} deriving Show

--sendGetRequest :: IO String
--sendGetRequest = simpleHTTP (getRequest _DEFINED_REQUEST_URL) >>= getResponseBody


getTheMovesRequest :: String -> String -> IO String
getTheMovesRequest requestUrl requestContentType = simpleHTTP (buildMyRequest) >>= getResponseBody
    where buildMyRequest = (getRequest url){ rqHeaders = makeHeadersForMyRequest }
          makeHeadersForMyRequest = [Header (HdrAccept) requestContentType]
          url = requestUrl

sendPostRequest :: String -> String -> String -> IO String
sendPostRequest move requestUrl requestContentType = simpleHTTP (postRequestWithBody (requestUrl) requestContentType move) >>= getResponseBody

--sendPostRequestAsEnemy :: String -> IO String
--sendPostRequestAsEnemy move = simpleHTTP (postRequestWithBody ("http://battleship.haskell.lt/game/" ++ _DEFINED_GAMESERVER_NAME ++ "/player/" ++ getEnemyPlayerId) _DEFINED_CONTENT_TYPE move) >>= getResponseBody

printBEncode :: BEncode -> IO ()
printBEncode s = do
    putStrLn (bShow s "")

addMyMove :: BattleshipsMsg -> BattleshipsMsg -> BattleshipsMsg
addMyMove fullList myMove
    | isNothing (bsMprev fullList) = BattleshipsMsg {bsMcoord = bsMcoord fullList, bsMresult = bsMresult fullList, bsMprev = Just myMove}
    | True = BattleshipsMsg {bsMcoord = bsMcoord fullList, bsMresult = bsMresult fullList, bsMprev = Just (addMyMove (fromJust (bsMprev fullList)) myMove)}

checkMyWin :: BattleshipsMsg -> Bool
checkMyWin msg
    | isNothing (bsMprev msg) = isNothing $ bsMcoord msg
    | True = checkMyWin (fromJust $ bsMprev msg)

getEnemyPlayerId :: String -> String
getEnemyPlayerId plId
    | plId == "A" = "B"
    | True = "A"

fillIfLast :: BattleshipsTable -> BattleshipsMsg -> BattleshipsMsg
fillIfLast table msg
    | isNothing (bsMprev msg) = fillOponentsResult table msg
    | True = BattleshipsMsg {bsMcoord = bsMcoord msg, bsMresult = bsMresult msg, bsMprev = Just (fillIfLast table (fromJust (bsMprev msg)))}


fillOponentsResult :: BattleshipsTable -> BattleshipsMsg -> BattleshipsMsg
fillOponentsResult table msg = do
    let shotCoords = bsMcoord msg
    if (isNothing shotCoords) then
        -- Seems like we have won.
        msg
    else do
        BattleshipsMsg {bsMcoord = shotCoords, bsMresult = Just (didShotHit table (fromJust shotCoords)), bsMprev = bsMprev msg}

-- region FROM FIRST PROGRAM
{-
Gets next available coordinate
-}
getNextCoord :: (Char, Int) -> Either String (Char, Int)
getNextCoord (letter, number)
  | ord letter >= ord 'J' && number >= 10 = Left "Board is full"
  | ord letter >= ord 'J' = Right ('A', number + 1)
  | ord letter < ord 'J' = Right (chr (ord letter + 1), number)
  | True = Left $ "Something went wrong while getting new coord." ++ ([letter] ++ show number)

{-
Check if coordinate aleady exists in current message
-}
checkIfCoordConflicts :: BattleshipsMsg -> (Char, Int) -> Bool
checkIfCoordConflicts bsM (letter, number)
  | isJust (bsMcoord bsM) == True && snd (fromJust (bsMcoord bsM)) == number && fst (fromJust (bsMcoord bsM)) == letter = True
  | True = False

{-
Check if with this coordinate, player has any spots.
-}
checkBsMMove :: BattleshipsMsg -> (Char, Int) -> Bool
checkBsMMove bsM (letter, number)
  | checkIfCoordConflicts bsM (letter, number) == True = True
  | isJust (bsMprev bsM) = checkBsMMove (fromJust (bsMprev bsM)) (letter, number)
  | True = False

{-
Iterate through all coordinates for the player
-}
checkAllBsMMoves :: BattleshipsMsg -> (Char, Int) -> Either String (Char, Int)
checkAllBsMMoves bsM (letter, number)
  | checkBsMMove bsM (letter, number) =
    let
      nextCoord = getNextCoord (letter, number)
      result =
        if isLeft nextCoord then
          Left (fromLeft "Something went horribly wrong, isLeft && fromLeft failed!" nextCoord)
        else
          checkAllBsMMoves bsM (fromRight ('A', 1) nextCoord)
    in
      result
  | True = Right (letter, number)

-- end region FROM FIRST PROGRAM

didShotHit :: BattleshipsTable -> (Char, Int) -> Bool
didShotHit table targetCoord = do
    let tableEntries = bsTentries table
    if (null tableEntries) then
        False
    else do
        let cur = head tableEntries
        if (areCoordsEqual cur targetCoord) then
            True
        else do
            didShotHit (BattleshipsTable {bsTentries = tail tableEntries}) targetCoord

checkMeAlive :: BattleshipsTable -> BattleshipsMsg -> Bool
checkMeAlive table attackerMsg = do
    -- iterate table and check if that coord was shot already
    let tableEntries = bsTentries table
    -- Iteration has reached the end of list. That means I lost.
    if (null tableEntries) then
        False
    else do
        let cur = head tableEntries
        -- if any of my ships still exists, I'm alive!
        if (checkCoordShot cur attackerMsg == False) then
            True
        else do
            checkMeAlive (BattleshipsTable {bsTentries = tail tableEntries}) attackerMsg

areCoordsEqual :: (Char, Int) -> (Char, Int) -> Bool
areCoordsEqual (c1, i1) (c2, i2) = c1 == c2 && i1 == i2

checkCoordShot :: (Char, Int) -> BattleshipsMsg -> Bool
checkCoordShot (ch, i) msg = do
    let currentCoord = bsMcoord msg
    if (isJust currentCoord && areCoordsEqual (ch, i) (fromJust currentCoord)) then
        True
    else do
        let prevMove = bsMprev msg
        if (isJust prevMove) then
            checkCoordShot (ch, i) (fromJust prevMove)
        else
            False

checkMoveBelongsToPlayerA :: BattleshipsMsg -> Bool
checkMoveBelongsToPlayerA msg = do
    let prevMove = bsMprev msg
    if (isNothing prevMove) then
        True
    else do
        let prevPrevMove = bsMprev (fromJust prevMove)
        if (isNothing prevPrevMove) then
            False
        else
            checkMoveBelongsToPlayerA (fromJust prevPrevMove)

-- If I am 'A' then should check all 'B' moves when I am dead.
-- Copied 2ice, could refactor.........
selectOnlyPlayerMoves :: [Char] -> BattleshipsMsg -> Maybe BattleshipsMsg
selectOnlyPlayerMoves "A" msg = do
    if (checkMoveBelongsToPlayerA msg) then do
        let prevMove = bsMprev msg
        if (isNothing prevMove) then
            Just BattleshipsMsg {bsMcoord = bsMcoord msg, bsMresult = bsMresult msg, bsMprev = Nothing}
        else do
            Just BattleshipsMsg {bsMcoord = bsMcoord msg, bsMresult = bsMresult msg, bsMprev = selectOnlyPlayerMoves "A" (fromJust prevMove)}
    else do
        let prevMove = bsMprev msg
        if (isNothing prevMove) then
            -- This shouldn't be possible...
            Just BattleshipsMsg {bsMcoord = Nothing, bsMresult = Nothing, bsMprev = Nothing}
        else do
            selectOnlyPlayerMoves "A" (fromJust prevMove)
selectOnlyPlayerMoves "B" msg = do
    if (checkMoveBelongsToPlayerA msg == False) then do
        let prevMove = bsMprev msg
        if (isNothing prevMove) then
            -- This shouldn't be possible...
            Just BattleshipsMsg {bsMcoord = Nothing, bsMresult = Nothing, bsMprev = Nothing}
        else do
            Just BattleshipsMsg {bsMcoord = bsMcoord msg, bsMresult = bsMresult msg, bsMprev = selectOnlyPlayerMoves "B" (fromJust prevMove)}
    else do
        let prevMove = bsMprev msg
        if (isNothing prevMove) then
            Nothing
        else do
            selectOnlyPlayerMoves "B" (fromJust prevMove)

-- region Convert To BEncode
coordToBEncode :: (Char, Int) -> (String, BEncode)
coordToBEncode (ch, i) = ("coord", BDict (Map.fromList [("1", BString (Bsl.fromStrict (Bs.pack [ch]))), ("2", BString (Bsl.fromStrict (Bs.pack (show i))))]))

resultToBEncode :: Bool -> (String, BEncode)
resultToBEncode b
    | b == True  = ("result", BString (Bsl.fromStrict (Bs.pack "HIT")))
    | b == False = ("result", BString (Bsl.fromStrict (Bs.pack "MISS")))

moveToBEncode :: BattleshipsMsg -> BEncode
moveToBEncode msg = do
    let resultVal = bsMresult msg
    if (isJust resultVal) then do
        let resultBe = resultToBEncode (fromJust resultVal)
        let coordVal = bsMcoord msg
        if (isJust coordVal) then do
            let coordBe = coordToBEncode (fromJust coordVal)
            let prevVal = bsMprev msg
            if(isJust prevVal) then do
                let prevBe = moveToBEncode (fromJust prevVal)
                BDict (Map.fromList [coordBe, ("prev", prevBe), resultBe])
            else do
                BDict (Map.fromList [coordBe, resultBe])
        else do
            let prevVal = bsMprev msg
            if(isJust prevVal) then do
                let prevBe = moveToBEncode (fromJust prevVal)
                BDict (Map.fromList [("prev", prevBe), resultBe])
            else do
                BDict (Map.fromList [resultBe])
    else do
        let coordVal = bsMcoord msg
        if (isJust coordVal) then do
            let coordBe = coordToBEncode (fromJust coordVal)
            let prevVal = bsMprev msg
            if(isJust prevVal) then do
                let prevBe = moveToBEncode (fromJust prevVal)
                BDict (Map.fromList [coordBe, ("prev", prevBe)])
            else do
                BDict (Map.fromList [coordBe])
        else do
            let prevVal = bsMprev msg
            if(isJust prevVal) then do
                let prevBe = moveToBEncode (fromJust prevVal)
                BDict (Map.fromList [("prev", prevBe)])
            else do
                BDict (Map.fromList [])
-- end region Convert To BEncode

-- region Parse From BEncode

note :: Maybe a -> e -> Either e a
note Nothing e = Left e
note (Just a) _ = Right a

parseBencode :: String -> Either String BEncode
parseBencode str = note (bRead (Bsl.fromStrict (Bs.pack str))) "BEncode parser has failed. Probably invalid BEncode format"

parseCoordDict :: BEncode -> Either String (Maybe (Char, Int))
parseCoordDict dictionary = do
    let parsingCoordResult = runParser (dict "coord") (dictionary)
    if (isLeft parsingCoordResult) then
        return Nothing
    else do
        coordLetterAsBeStr <- runParser (dict "1") (fromRight (BInt 0) parsingCoordResult)
        coordLetterAsStr <- runParser (bstring token) coordLetterAsBeStr
        let coordChar = head coordLetterAsStr
        if (ord coordChar > ord 'J' || ord coordChar < ord 'A') then
            Left "Invalid coordinate letter!"
        else do
            coordNumberAsBeStr <- runParser (dict "2") (fromRight (BInt 0) parsingCoordResult)
            coordNumberAsStr <- runParser (bstring token) coordNumberAsBeStr
            let numberAsInt = read coordNumberAsStr
            if (numberAsInt < 1 || numberAsInt > 10) then
                Left "Invalid coordinate number found!"
            else do
                return (Just ((head coordLetterAsStr), numberAsInt))


parsePrevDict dictionary = runParser (dict "prev") (dictionary)

parseResultDict :: BEncode -> Either String (Maybe Bool)
parseResultDict dictionary = do
    let parsingResultResult = runParser (dict "result") (dictionary)
    if (isLeft parsingResultResult) then
        return Nothing
    else do
        resultStr <- runParser (bstring token) (fromRight (BInt 0) parsingResultResult)
        if (resultStr == "MISS") then
            return (Just False)
        else if (resultStr == "HIT") then
            return (Just True)
        else do
            Left "Invalid result value"

parseAMove :: BEncode -> Either String BattleshipsMsg
parseAMove bencode = do
    coords <- parseCoordDict bencode
    result <- parseResultDict bencode
    let parsingPrevResult = parsePrevDict bencode
    if (isLeft parsingPrevResult) then
        return BattleshipsMsg {bsMcoord = coords, bsMresult = result, bsMprev = Nothing}
    else do
        prevValue <- parseAMove (fromRight (BInt 0) parsingPrevResult)
        return BattleshipsMsg {bsMcoord = coords, bsMresult = result, bsMprev = Just prevValue}

parseAllMoves :: String -> Either String BattleshipsMsg
parseAllMoves msg = do
    allBencode <- parseBencode msg
    parsed <- parseAMove allBencode
    return parsed

-- end region Parse From BEncode

