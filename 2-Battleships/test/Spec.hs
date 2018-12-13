
import Test.Tasty
import Test.Tasty.SmallCheck as SC
import Test.Tasty.QuickCheck as QC
import Test.Tasty.HUnit

import Data.Either
import Data.BEncode

import Lib

main = defaultMain tests

tests :: TestTree
tests = testGroup "Tests" [unitTests]
unitTests = testGroup "Unit tests"
  [ testCase "Parsing from and back to BEncode" $
  bShow (moveToBEncode (fromRight (BattleshipsMsg {bsMcoord = Nothing, bsMresult = Nothing, bsMprev = Nothing}) (parseAllMoves "d5:coordd1:11:F1:21:1e4:prevd5:coordd1:11:F1:21:1ee6:result4:MISSe"))) "" `compare` "d5:coordd1:11:F1:21:1e4:prevd5:coordd1:11:F1:21:1ee6:result4:MISSe" @?= EQ
  ]
