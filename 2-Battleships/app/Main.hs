module Main where

import Lib


import Data.Maybe
import Data.Either
import Data.Char
import qualified Data.Map.Strict as Map
import Data.Map (Map())
import Control.Exception

import Data.BEncode
import Data.BEncode.Parser
import Data.BEncode.Lexer



{-
BattleshipsMsg {bsMcoord = Just ('A', 3), bsMresult = Just False, bsMprev = Just BattleshipsMsg {bsMcoord = Just ('B', 4), bsMresult  = Nothing, bsMprev = Nothing}}


Idea:
Player A posts first move;
Player B gets the move, makes it's own, sends back
...

Need to:
Place my ships. ------ a way to save all the data. Probably whole table is enough.
Get move
Parse bencode, find all moves.
Add my own move to whole list.
Post with move
if all my ships down, send empty string -> defeat.

-------------------
Turn Bencode to my type and vice versa?


------------------------
    A        B        A       B        A
A2
A2:false;A1
A2:false;A1:true;A1
A2:false;A1:true;A1:false;B2
A2:false;A1:true;A1:false;B2:false;C3
...


-}

{-

Generate ships.
Move command.
Get/Post
-}



-- 5 ships T formation.

-- +--+-+-+-+-+-+-+-+-+-+-+    +--+-+-+-+-+-+-+-+-+-+-+
-- |  |A|B|C|D|E|F|G|H|I|J|    |  |A|B|C|D|E|F|G|H|I|J|
-- +--+-+-+-+-+-+-+-+-+-+-+    +--+-+-+-+-+-+-+-+-+-+-+
-- | 1|x|x|x| |x|x|x| | | |    | 1| | | | | | | | | | |
-- +--+-+-+-+-+-+-+-+-+-+-+    +--+-+-+-+-+-+-+-+-+-+-+
-- | 2| |x| | | |x| | | | |    | 2|?| | | | | | | | | |
-- +--+-+-+-+-+-+-+-+-+-+-+    +--+-+-+-+-+-+-+-+-+-+-+
-- | 3| | | |x| | | |x| | |    | 3| | | | | | | | | | |
-- +--+-+-+-+-+-+-+-+-+-+-+    +--+-+-+-+-+-+-+-+-+-+-+
-- | 4| | | |x|x| |x|x|x| |    | 4| | | | | | | | | | |
-- +--+-+-+-+-+-+-+-+-+-+-+    +--+-+-+-+-+-+-+-+-+-+-+
-- | 5| | | |x| | | | | | |    | 5| |*| | | | | | | | |
-- +--+-+-+-+-+-+-+-+-+-+-+    +--+-+-+-+-+-+-+-+-+-+-+
-- | 6| | |x| | | | | | | |    | 6| | | | | | | | | | |
-- +--+-+-+-+-+-+-+-+-+-+-+    +--+-+-+-+-+-+-+-+-+-+-+
-- | 7| |x|x| | | | | | | |    | 7| | | | | | | | | | |
-- +--+-+-+-+-+-+-+-+-+-+-+    +--+-+-+-+-+-+-+-+-+-+-+
-- | 8| | |x| | | | | | | |    | 8| | | | | | | | | | |
-- +--+-+-+-+-+-+-+-+-+-+-+    +--+-+-+-+-+-+-+-+-+-+-+
-- | 9| | | | | | | | | | |    | 9| | | | | | | | | | |
-- +--+-+-+-+-+-+-+-+-+-+-+    +--+-+-+-+-+-+-+-+-+-+-+
-- |10| | | | | | | | | | |    |10| | | | | | | | | | |
-- +--+-+-+-+-+-+-+-+-+-+-+    +--+-+-+-+-+-+-+-+-+-+-+

-- A1,B1,C1,B2, E1,F1,G1,F2, D3,D4,E4,D5, H3,G4,H4,I4, C6,B7,C7,C8
-- ('A', 1),('B', 1),('C', 1),('B', 2), ('E', 1),('F', 1),('G', 1),('F', 2), ('D', 3),('D', 4),('E', 4),('D', 5), ('H', 3),('G', 4),('H', 4),('I', 4), ('C', 6),('B', 7),('C', 7),('C', 8)
_MY_SHIPS_ON_TABLE = BattleshipsTable {bsTentries = [('A', 1),('B', 1),('C', 1),('B', 2), ('E', 1),('F', 1),('G', 1),('F', 2), ('D', 3),('D', 4),('E', 4),('D', 5), ('H', 3),('G', 4),('H', 4),('I', 4), ('C', 6),('B', 7),('C', 7),('C', 8)]}

_DEFINED_CONTENT_TYPE = "application/bencoding+nolists"

getRequestUrl :: String -> String -> String
getRequestUrl gameServerName playerId = "http://battleship.haskell.lt/game/" ++ gameServerName ++ "/player/" ++ playerId

main :: IO ()
main = do
    putStrLn "PlayerID (A/B):"
    playerId <- getLine
    if (playerId /= "A" && playerId /= "B") then
        putStrLn $ "Invalid Player ID: " ++ playerId
    else do
        putStrLn "GameServer name:"
        gameServerName <- getLine
        if (length gameServerName < 1) then
            putStrLn "GameServer name invalid"
        else do
            if (playerId == "A") then do
                let bmsg = BattleshipsMsg {bsMcoord = Just ('A', 1), bsMresult = Nothing, bsMprev = Nothing}
                let toSend = bShow (moveToBEncode bmsg) ""
                postResponseStr <- sendPostRequest toSend (getRequestUrl gameServerName playerId) _DEFINED_CONTENT_TYPE
                putStrLn $ "Starting the game. Response: " ++ postResponseStr
                mainMoves gameServerName playerId
            else do
                mainMoves gameServerName playerId

parserExceptionHandler :: SomeException -> IO (Either String BattleshipsMsg)
parserExceptionHandler _ = return (Left ("BEncode library Has thrown an exception"))

mainMoves :: String -> String -> IO ()
mainMoves gameServerName playerId = do
    gotBencode <- getTheMovesRequest (getRequestUrl gameServerName playerId) _DEFINED_CONTENT_TYPE
    parsedBsMoves <- catch (return (parseAllMoves gotBencode)) parserExceptionHandler
    if (isLeft parsedBsMoves) then
        -- Can't parse Bencode, can't continue!.
        putStrLn "BEncode parsing has failed, can't continue."
    else do
        let parsedBsMovesR = fromRight (BattleshipsMsg {bsMcoord = Nothing, bsMresult = Nothing, bsMprev = Nothing}) parsedBsMoves
        if (checkMyWin parsedBsMovesR) then
            putStrLn "I won!"
        else do
            let parsedBsMovesFilled = fillIfLast _MY_SHIPS_ON_TABLE parsedBsMovesR
            let enemyPlayerMoves = selectOnlyPlayerMoves (getEnemyPlayerId playerId) parsedBsMovesFilled
            let meAlive = isNothing enemyPlayerMoves || checkMeAlive _MY_SHIPS_ON_TABLE (fromJust enemyPlayerMoves)
            if (meAlive == False) then do
                -- add empty dict and send... I lost...
                let toSend = bShow (moveToBEncode $ addMyMove parsedBsMovesFilled BattleshipsMsg {bsMcoord = Nothing, bsMresult = Nothing, bsMprev = Nothing}) ""
                postResponseStr <- sendPostRequest toSend (getRequestUrl gameServerName playerId) _DEFINED_CONTENT_TYPE
                putStrLn $ "I lost... Sending loosing message... response: " ++ postResponseStr
            else do
                -- add my own move.
                let nextMove = checkAllBsMMoves (fromJust (selectOnlyPlayerMoves (getEnemyPlayerId playerId) (parsedBsMovesFilled))) ('A', 1)
                if (isLeft nextMove) then do
                    -- nowhere to move anymore...
                    -- Send surrender message?
                    let toSend = bShow (moveToBEncode $ addMyMove parsedBsMovesFilled BattleshipsMsg {bsMcoord = Nothing, bsMresult = Nothing, bsMprev = Nothing}) ""
                    postResponseStr <- sendPostRequest toSend (getRequestUrl gameServerName playerId) _DEFINED_CONTENT_TYPE
                    putStrLn $ "Next move position was not found. Can't continue, sending loss message. response: " ++ postResponseStr
                else do
                    let nextMoveR = fromRight ('A', 1) nextMove
                    let toSend = bShow (moveToBEncode $ addMyMove parsedBsMovesFilled BattleshipsMsg {bsMcoord = Just nextMoveR, bsMresult = Nothing, bsMprev = Nothing}) ""
                    postResponseStr <- sendPostRequest toSend (getRequestUrl gameServerName playerId) _DEFINED_CONTENT_TYPE
                    putStrLn toSend
                    putStrLn $ "Made a move, sending... response: " ++ postResponseStr
                    mainMoves gameServerName playerId












{-
parseBencodeToMyType :: String -> BattleshipsMsg
parseBencodeToMyType msg = do
    return bsTentries [[]]

-}
    {-

parseBencodeToMyTypeInternal :: BEncode -> BattleshipsMsg
parseBencodeToMyTypeInternal benc = do
    putStrLn "Not implemented"
    -}


{-
http://hackage.haskell.org/package/bencode-0.6.0.0/docs/Data-BEncode.html
http://hackage.haskell.org/package/bencode-0.6.0.0/docs/Data-BEncode-Parser.html
-}
{-
Get value from dictionary.
fromRight (BInt 5) ( runParser (dict "1") (fromJust (bRead (Bsl.fromStrict (Bs.pack "d1:11:A1:21:4e")))))
-}
{-
Get string!
runParser (bstring token) (parseBencode "5:coord")
-}
