-- 26 nr
-- Tshapes
-- bencoding w/o lists
import Board
import Data.Char
import Data.List
import Data.Maybe
import Data.Either

data BattleshipsMsg = BattleshipsMsg {
  bsMcoord :: Maybe (Char, Int),
  bsMresult :: Maybe Bool,
  bsMprev :: Maybe BattleshipsMsg
} deriving Show

{-
1 move left:
d5:coordde4:prevd5:coordd1:11:D1:21:1e4:prevd5:coordd1:11:H1:21:3e4:prevd5:coordd1:11:J1:21:3e4:prevd5:coordd1:11:I1:21:9e4:prevd5:coordd1:11:C1:21:4e4:prevd5:coordd1:11:H1:21:6e4:prevd5:coordd1:11:E1:21:5e4:prevd5:coordd1:11:D1:21:5e4:prevd5:coordd1:11:C1:21:7e4:prevd5:coordd1:11:G1:21:7e4:prevd5:coordd1:11:A1:21:2e4:prevd5:coordd1:11:G1:21:9e4:prevd5:coordd1:11:F1:21:5e4:prevd5:coordd1:11:A1:21:9e4:prevd5:coordd1:11:A1:21:4e4:prevd5:coordd1:11:E1:21:5e4:prevd5:coordd1:11:D1:21:5e4:prevd5:coordd1:11:B1:21:6e4:prevd5:coordd1:11:B1:21:3e4:prevd5:coordd1:11:I1:21:5e4:prevd5:coordd1:11:G1:21:9e4:prevd5:coordd1:11:D1:21:3e4:prevd5:coordd1:11:A1:22:10e4:prevd5:coordd1:11:A1:22:10e4:prevd5:coordd1:11:B1:21:6e4:prevd5:coordd1:11:E1:21:9e4:prevd5:coordd1:11:B1:21:9e4:prevd5:coordd1:11:G1:21:6e4:prevd5:coordd1:11:C1:21:8e4:prevd5:coordd1:11:J1:21:1e4:prevd5:coordd1:11:D1:21:2e4:prevd5:coordd1:11:A1:21:4e4:prevd5:coordd1:11:J1:21:9e4:prevd5:coordd1:11:A1:21:3e4:prevd5:coordd1:11:D1:21:8e4:prevd5:coordd1:11:F1:21:5e4:prevd5:coordd1:11:J1:21:1e4:prevd5:coordd1:11:G1:21:1e4:prevd5:coordd1:11:C1:22:10e4:prevd5:coordd1:11:H1:21:5e4:prevd5:coordd1:11:I1:21:2e4:prevd5:coordd1:11:H1:21:9e4:prevd5:coordd1:11:A1:21:6e4:prevd5:coordd1:11:E1:22:10e4:prevd5:coordd1:11:F1:21:6e4:prevd5:coordd1:11:F1:21:6e4:prevd5:coordd1:11:F1:21:4e4:prevd5:coordd1:11:I1:21:1e4:prevd5:coordd1:11:F1:21:2e4:prevd5:coordd1:11:C1:21:4e4:prevd5:coordd1:11:E1:21:6e4:prevd5:coordd1:11:A1:21:8e4:prevd5:coordd1:11:G1:21:5e4:prevd5:coordd1:11:F1:21:9e4:prevd5:coordd1:11:I1:21:3e4:prevd5:coordd1:11:G1:22:10e4:prevd5:coordd1:11:G1:21:4e4:prevd5:coordd1:11:A1:21:5e4:prevd5:coordd1:11:I1:21:5e4:prevd5:coordd1:11:D1:22:10e4:prevd5:coordd1:11:H1:21:2e4:prevd5:coordd1:11:A1:21:6e4:prevd5:coordd1:11:D1:21:7e4:prevd5:coordd1:11:F1:21:3e4:prevd5:coordd1:11:D1:21:3e4:prevd5:coordd1:11:B1:21:5e4:prevd5:coordd1:11:E1:21:3e4:prevd5:coordd1:11:A1:21:7e4:prevd5:coordd1:11:I1:21:8e4:prevd5:coordd1:11:H1:22:10e4:prevd5:coordd1:11:H1:21:5e4:prevd5:coordd1:11:E1:21:6e4:prevd5:coordd1:11:I1:21:4e4:prevd5:coordd1:11:E1:21:2e4:prevd5:coordd1:11:A1:21:9e4:prevd5:coordd1:11:C1:21:6e4:prevd5:coordd1:11:E1:21:9e4:prevd5:coordd1:11:J1:21:7e4:prevd5:coordd1:11:J1:21:4e4:prevd5:coordd1:11:J1:22:10e4:prevd5:coordd1:11:I1:22:10e4:prevd5:coordd1:11:I1:21:3e4:prevd5:coordd1:11:E1:21:7e4:prevd5:coordd1:11:C1:21:8e4:prevd5:coordd1:11:I1:21:1e4:prevd5:coordd1:11:H1:21:7e4:prevd5:coordd1:11:J1:22:10e4:prevd5:coordd1:11:G1:21:4e4:prevd5:coordd1:11:H1:21:9e4:prevd5:coordd1:11:G1:21:8e4:prevd5:coordd1:11:B1:21:8e4:prevd5:coordd1:11:E1:21:7e4:prevd5:coordd1:11:D1:21:9e4:prevd5:coordd1:11:G1:21:5e4:prevd5:coordd1:11:H1:21:3e4:prevd5:coordd1:11:A1:21:2e4:prevd5:coordd1:11:B1:21:1e4:prevd5:coordd1:11:C1:21:3e4:prevd5:coordd1:11:B1:21:4e4:prevd5:coordd1:11:F1:21:7e4:prevd5:coordd1:11:J1:21:5e4:prevd5:coordd1:11:I1:21:4e4:prevd5:coordd1:11:D1:21:6e4:prevd5:coordd1:11:I1:21:8e4:prevd5:coordd1:11:F1:21:7e4:prevd5:coordd1:11:G1:21:2e4:prevd5:coordd1:11:G1:21:7e4:prevd5:coordd1:11:D1:21:2e4:prevd5:coordd1:11:C1:21:2e4:prevd5:coordd1:11:A1:21:1e4:prevd5:coordd1:11:G1:21:2e4:prevd5:coordd1:11:B1:21:8e4:prevd5:coordd1:11:G1:21:6e4:prevd5:coordd1:11:C1:21:9e4:prevd5:coordd1:11:C1:21:5e4:prevd5:coordd1:11:C1:21:7e4:prevd5:coordd1:11:E1:21:8e4:prevd5:coordd1:11:E1:21:1e4:prevd5:coordd1:11:G1:22:10e4:prevd5:coordd1:11:J1:21:8e4:prevd5:coordd1:11:C1:21:1e4:prevd5:coordd1:11:B1:21:7e4:prevd5:coordd1:11:F1:21:1e4:prevd5:coordd1:11:B1:21:3e4:prevd5:coordd1:11:J1:21:6e4:prevd5:coordd1:11:F1:21:4e4:prevd5:coordd1:11:C1:21:9e4:prevd5:coordd1:11:J1:21:3e4:prevd5:coordd1:11:D1:21:4e4:prevd5:coordd1:11:D1:21:4e4:prevd5:coordd1:11:J1:21:8e4:prevd5:coordd1:11:B1:21:4e4:prevd5:coordd1:11:E1:22:10e4:prevd5:coordd1:11:I1:21:6e4:prevd5:coordd1:11:H1:22:10e4:prevd5:coordd1:11:F1:22:10e4:prevd5:coordd1:11:A1:21:1e4:prevd5:coordd1:11:C1:21:5e4:prevd5:coordd1:11:E1:21:2e4:prevd5:coordd1:11:C1:21:2e4:prevd5:coordd1:11:C1:21:6e4:prevd5:coordd1:11:C1:21:1e4:prevd5:coordd1:11:H1:21:8e4:prevd5:coordd1:11:I1:21:7e4:prevd5:coordd1:11:I1:21:7e4:prevd5:coordd1:11:H1:21:2e4:prevd5:coordd1:11:D1:22:10e4:prevd5:coordd1:11:J1:21:5e4:prevd5:coordd1:11:A1:21:5e4:prevd5:coordd1:11:F1:21:2e4:prevd5:coordd1:11:G1:21:1e4:prevd5:coordd1:11:D1:21:8e4:prevd5:coordd1:11:A1:21:8e4:prevd5:coordd1:11:B1:21:2e4:prevd5:coordd1:11:A1:21:3e4:prevd5:coordd1:11:J1:21:4e4:prevd5:coordd1:11:B1:21:2e4:prevd5:coordd1:11:J1:21:6e4:prevd5:coordd1:11:G1:21:8e4:prevd5:coordd1:11:I1:22:10e4:prevd5:coordd1:11:A1:21:7e4:prevd5:coordd1:11:I1:21:2e4:prevd5:coordd1:11:B1:21:5e4:prevd5:coordd1:11:H1:21:1e4:prevd5:coordd1:11:E1:21:4e4:prevd5:coordd1:11:B1:21:1e4:prevd5:coordd1:11:F1:21:9e4:prevd5:coordd1:11:E1:21:3e4:prevd5:coordd1:11:B1:22:10e4:prevd5:coordd1:11:D1:21:7e4:prevd5:coordd1:11:H1:21:1e4:prevd5:coordd1:11:H1:21:4e4:prevd5:coordd1:11:F1:22:10e4:prevd5:coordd1:11:D1:21:6e4:prevd5:coordd1:11:H1:21:4e4:prevd5:coordd1:11:F1:21:8e4:prevd5:coordd1:11:F1:21:8e4:prevd5:coordd1:11:D1:21:1e4:prevd5:coordd1:11:G1:21:3e4:prevd5:coordd1:11:E1:21:4e4:prevd5:coordd1:11:C1:21:3e4:prevd5:coordd1:11:B1:22:10e4:prevd5:coordd1:11:J1:21:7e4:prevd5:coordd1:11:D1:21:9e4:prevd5:coordd1:11:E1:21:1e4:prevd5:coordd1:11:J1:21:9e4:prevd5:coordd1:11:B1:21:7e4:prevd5:coordd1:11:E1:21:8e4:prevd5:coordd1:11:F1:21:3e4:prevd5:coordd1:11:F1:21:1e4:prevd5:coordd1:11:I1:21:9e4:prevd5:coordd1:11:C1:22:10e4:prevd5:coordd1:11:H1:21:6e4:prevd5:coordd1:11:B1:21:9e4:prevd5:coordd1:11:H1:21:7e4:prevd5:coordd1:11:G1:21:3e4:prevd5:coordd1:11:I1:21:6e4:prevd5:coordd1:11:H1:21:8e4:prevd5:coordd1:11:J1:21:2ee6:result3:HITe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result3:HITe6:result4:MISSe6:result3:HITe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result3:HITe6:result3:HITe6:result4:MISSe6:result4:MISSe6:result3:HITe6:result3:HITe6:result3:HITe6:result4:MISSe6:result4:MISSe6:result3:HITe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result3:HITe6:result4:MISSe6:result3:HITe6:result3:HITe6:result4:MISSe6:result4:MISSe6:result3:HITe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result3:HITe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result3:HITe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result3:HITe6:result4:MISSe6:result3:HITe6:result4:MISSe6:result3:HITe6:result4:MISSe6:result3:HITe6:result4:MISSe6:result4:MISSe6:result3:HITe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result3:HITe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result3:HITe6:result4:MISSe6:result3:HITe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result3:HITe6:result4:MISSe6:result4:MISSe6:result3:HITe6:result4:MISSe6:result4:MISSe6:result3:HITe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result3:HITe6:result3:HITe6:result4:MISSe6:result3:HITe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result3:HITe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result3:HITe6:result4:MISSe6:result4:MISSe6:result3:HITe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result3:HITe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result3:HITe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result3:HITe6:result4:MISSe6:result3:HITe6:result3:HITe6:result3:HITe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result3:HITe6:result3:HITe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result3:HITe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result3:HITe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result3:HITe6:result4:MISSe6:result4:MISSe6:result3:HITe6:result3:HITe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result3:HITe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result3:HITe6:result3:HITe6:result3:HITe

Full board:
d5:coordd1:11:J1:21:2e4:prevd5:coordd1:11:D1:21:1e4:prevd5:coordd1:11:H1:21:3e4:prevd5:coordd1:11:J1:21:3e4:prevd5:coordd1:11:I1:21:9e4:prevd5:coordd1:11:C1:21:4e4:prevd5:coordd1:11:H1:21:6e4:prevd5:coordd1:11:E1:21:5e4:prevd5:coordd1:11:D1:21:5e4:prevd5:coordd1:11:C1:21:7e4:prevd5:coordd1:11:G1:21:7e4:prevd5:coordd1:11:A1:21:2e4:prevd5:coordd1:11:G1:21:9e4:prevd5:coordd1:11:F1:21:5e4:prevd5:coordd1:11:A1:21:9e4:prevd5:coordd1:11:A1:21:4e4:prevd5:coordd1:11:E1:21:5e4:prevd5:coordd1:11:D1:21:5e4:prevd5:coordd1:11:B1:21:6e4:prevd5:coordd1:11:B1:21:3e4:prevd5:coordd1:11:I1:21:5e4:prevd5:coordd1:11:G1:21:9e4:prevd5:coordd1:11:D1:21:3e4:prevd5:coordd1:11:A1:22:10e4:prevd5:coordd1:11:A1:22:10e4:prevd5:coordd1:11:B1:21:6e4:prevd5:coordd1:11:E1:21:9e4:prevd5:coordd1:11:B1:21:9e4:prevd5:coordd1:11:G1:21:6e4:prevd5:coordd1:11:C1:21:8e4:prevd5:coordd1:11:J1:21:1e4:prevd5:coordd1:11:D1:21:2e4:prevd5:coordd1:11:A1:21:4e4:prevd5:coordd1:11:J1:21:9e4:prevd5:coordd1:11:A1:21:3e4:prevd5:coordd1:11:D1:21:8e4:prevd5:coordd1:11:F1:21:5e4:prevd5:coordd1:11:J1:21:1e4:prevd5:coordd1:11:G1:21:1e4:prevd5:coordd1:11:C1:22:10e4:prevd5:coordd1:11:H1:21:5e4:prevd5:coordd1:11:I1:21:2e4:prevd5:coordd1:11:H1:21:9e4:prevd5:coordd1:11:A1:21:6e4:prevd5:coordd1:11:E1:22:10e4:prevd5:coordd1:11:F1:21:6e4:prevd5:coordd1:11:F1:21:6e4:prevd5:coordd1:11:F1:21:4e4:prevd5:coordd1:11:I1:21:1e4:prevd5:coordd1:11:F1:21:2e4:prevd5:coordd1:11:C1:21:4e4:prevd5:coordd1:11:E1:21:6e4:prevd5:coordd1:11:A1:21:8e4:prevd5:coordd1:11:G1:21:5e4:prevd5:coordd1:11:F1:21:9e4:prevd5:coordd1:11:I1:21:3e4:prevd5:coordd1:11:G1:22:10e4:prevd5:coordd1:11:G1:21:4e4:prevd5:coordd1:11:A1:21:5e4:prevd5:coordd1:11:I1:21:5e4:prevd5:coordd1:11:D1:22:10e4:prevd5:coordd1:11:H1:21:2e4:prevd5:coordd1:11:A1:21:6e4:prevd5:coordd1:11:D1:21:7e4:prevd5:coordd1:11:F1:21:3e4:prevd5:coordd1:11:D1:21:3e4:prevd5:coordd1:11:B1:21:5e4:prevd5:coordd1:11:E1:21:3e4:prevd5:coordd1:11:A1:21:7e4:prevd5:coordd1:11:I1:21:8e4:prevd5:coordd1:11:H1:22:10e4:prevd5:coordd1:11:H1:21:5e4:prevd5:coordd1:11:E1:21:6e4:prevd5:coordd1:11:I1:21:4e4:prevd5:coordd1:11:E1:21:2e4:prevd5:coordd1:11:A1:21:9e4:prevd5:coordd1:11:C1:21:6e4:prevd5:coordd1:11:E1:21:9e4:prevd5:coordd1:11:J1:21:7e4:prevd5:coordd1:11:J1:21:4e4:prevd5:coordd1:11:J1:22:10e4:prevd5:coordd1:11:I1:22:10e4:prevd5:coordd1:11:I1:21:3e4:prevd5:coordd1:11:E1:21:7e4:prevd5:coordd1:11:C1:21:8e4:prevd5:coordd1:11:I1:21:1e4:prevd5:coordd1:11:H1:21:7e4:prevd5:coordd1:11:J1:22:10e4:prevd5:coordd1:11:G1:21:4e4:prevd5:coordd1:11:H1:21:9e4:prevd5:coordd1:11:G1:21:8e4:prevd5:coordd1:11:B1:21:8e4:prevd5:coordd1:11:E1:21:7e4:prevd5:coordd1:11:D1:21:9e4:prevd5:coordd1:11:G1:21:5e4:prevd5:coordd1:11:H1:21:3e4:prevd5:coordd1:11:A1:21:2e4:prevd5:coordd1:11:B1:21:1e4:prevd5:coordd1:11:C1:21:3e4:prevd5:coordd1:11:B1:21:4e4:prevd5:coordd1:11:F1:21:7e4:prevd5:coordd1:11:J1:21:5e4:prevd5:coordd1:11:I1:21:4e4:prevd5:coordd1:11:D1:21:6e4:prevd5:coordd1:11:I1:21:8e4:prevd5:coordd1:11:F1:21:7e4:prevd5:coordd1:11:G1:21:2e4:prevd5:coordd1:11:G1:21:7e4:prevd5:coordd1:11:D1:21:2e4:prevd5:coordd1:11:C1:21:2e4:prevd5:coordd1:11:A1:21:1e4:prevd5:coordd1:11:G1:21:2e4:prevd5:coordd1:11:B1:21:8e4:prevd5:coordd1:11:G1:21:6e4:prevd5:coordd1:11:C1:21:9e4:prevd5:coordd1:11:C1:21:5e4:prevd5:coordd1:11:C1:21:7e4:prevd5:coordd1:11:E1:21:8e4:prevd5:coordd1:11:E1:21:1e4:prevd5:coordd1:11:G1:22:10e4:prevd5:coordd1:11:J1:21:8e4:prevd5:coordd1:11:C1:21:1e4:prevd5:coordd1:11:B1:21:7e4:prevd5:coordd1:11:F1:21:1e4:prevd5:coordd1:11:B1:21:3e4:prevd5:coordd1:11:J1:21:6e4:prevd5:coordd1:11:F1:21:4e4:prevd5:coordd1:11:C1:21:9e4:prevd5:coordd1:11:J1:21:3e4:prevd5:coordd1:11:D1:21:4e4:prevd5:coordd1:11:D1:21:4e4:prevd5:coordd1:11:J1:21:8e4:prevd5:coordd1:11:B1:21:4e4:prevd5:coordd1:11:E1:22:10e4:prevd5:coordd1:11:I1:21:6e4:prevd5:coordd1:11:H1:22:10e4:prevd5:coordd1:11:F1:22:10e4:prevd5:coordd1:11:A1:21:1e4:prevd5:coordd1:11:C1:21:5e4:prevd5:coordd1:11:E1:21:2e4:prevd5:coordd1:11:C1:21:2e4:prevd5:coordd1:11:C1:21:6e4:prevd5:coordd1:11:C1:21:1e4:prevd5:coordd1:11:H1:21:8e4:prevd5:coordd1:11:I1:21:7e4:prevd5:coordd1:11:I1:21:7e4:prevd5:coordd1:11:H1:21:2e4:prevd5:coordd1:11:D1:22:10e4:prevd5:coordd1:11:J1:21:5e4:prevd5:coordd1:11:A1:21:5e4:prevd5:coordd1:11:F1:21:2e4:prevd5:coordd1:11:G1:21:1e4:prevd5:coordd1:11:D1:21:8e4:prevd5:coordd1:11:A1:21:8e4:prevd5:coordd1:11:B1:21:2e4:prevd5:coordd1:11:A1:21:3e4:prevd5:coordd1:11:J1:21:4e4:prevd5:coordd1:11:B1:21:2e4:prevd5:coordd1:11:J1:21:6e4:prevd5:coordd1:11:G1:21:8e4:prevd5:coordd1:11:I1:22:10e4:prevd5:coordd1:11:A1:21:7e4:prevd5:coordd1:11:I1:21:2e4:prevd5:coordd1:11:B1:21:5e4:prevd5:coordd1:11:H1:21:1e4:prevd5:coordd1:11:E1:21:4e4:prevd5:coordd1:11:B1:21:1e4:prevd5:coordd1:11:F1:21:9e4:prevd5:coordd1:11:E1:21:3e4:prevd5:coordd1:11:B1:22:10e4:prevd5:coordd1:11:D1:21:7e4:prevd5:coordd1:11:H1:21:1e4:prevd5:coordd1:11:H1:21:4e4:prevd5:coordd1:11:F1:22:10e4:prevd5:coordd1:11:D1:21:6e4:prevd5:coordd1:11:H1:21:4e4:prevd5:coordd1:11:F1:21:8e4:prevd5:coordd1:11:F1:21:8e4:prevd5:coordd1:11:D1:21:1e4:prevd5:coordd1:11:G1:21:3e4:prevd5:coordd1:11:E1:21:4e4:prevd5:coordd1:11:C1:21:3e4:prevd5:coordd1:11:B1:22:10e4:prevd5:coordd1:11:J1:21:7e4:prevd5:coordd1:11:D1:21:9e4:prevd5:coordd1:11:E1:21:1e4:prevd5:coordd1:11:J1:21:9e4:prevd5:coordd1:11:B1:21:7e4:prevd5:coordd1:11:E1:21:8e4:prevd5:coordd1:11:F1:21:3e4:prevd5:coordd1:11:F1:21:1e4:prevd5:coordd1:11:I1:21:9e4:prevd5:coordd1:11:C1:22:10e4:prevd5:coordd1:11:H1:21:6e4:prevd5:coordd1:11:B1:21:9e4:prevd5:coordd1:11:H1:21:7e4:prevd5:coordd1:11:G1:21:3e4:prevd5:coordd1:11:I1:21:6e4:prevd5:coordd1:11:H1:21:8e4:prevd5:coordd1:11:J1:21:2ee6:result3:HITe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result3:HITe6:result4:MISSe6:result3:HITe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result3:HITe6:result3:HITe6:result4:MISSe6:result4:MISSe6:result3:HITe6:result3:HITe6:result3:HITe6:result4:MISSe6:result4:MISSe6:result3:HITe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result3:HITe6:result4:MISSe6:result3:HITe6:result3:HITe6:result4:MISSe6:result4:MISSe6:result3:HITe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result3:HITe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result3:HITe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result3:HITe6:result4:MISSe6:result3:HITe6:result4:MISSe6:result3:HITe6:result4:MISSe6:result3:HITe6:result4:MISSe6:result4:MISSe6:result3:HITe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result3:HITe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result3:HITe6:result4:MISSe6:result3:HITe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result3:HITe6:result4:MISSe6:result4:MISSe6:result3:HITe6:result4:MISSe6:result4:MISSe6:result3:HITe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result3:HITe6:result3:HITe6:result4:MISSe6:result3:HITe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result3:HITe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result3:HITe6:result4:MISSe6:result4:MISSe6:result3:HITe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result3:HITe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result3:HITe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result3:HITe6:result4:MISSe6:result3:HITe6:result3:HITe6:result3:HITe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result3:HITe6:result3:HITe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result3:HITe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result3:HITe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result3:HITe6:result4:MISSe6:result4:MISSe6:result3:HITe6:result3:HITe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result3:HITe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result4:MISSe6:result3:HITe6:result3:HITe6:result3:HITe

-}

-- d5:coordd1:11:A1:21:8e4:prevd5:coordd1:11:D1:21:5e4:prevd5:coordd1:11:I1:21:3e4:prevd5:coordd1:11:H1:21:2e4:prevd5:coordd1:11:F1:21:7e4:prevd5:coordd1:11:D1:21:3e4:prevd5:coordd1:11:A1:22:10ee6:result3:HITe6:result3:HITe6:result4:MISSe6:result3:HITe6:result4:MISSe6:result4:MISSe
{-
d5:coordd1:11:F1:21:1e4:prevd5:coordd1:11:F1:21:1ee6:result4:MISSe
d5:coordd1:11:A1:21:1ee
-}

move :: String -> Either String (Maybe [String])
move board = move1 board

{-
Wrapper. Why? Not sure.
-}
move1 :: String -> Either String (Maybe [String])
move1 board =
  case parseSingleMove board of
    Left e1 -> Left e1
    Right (Nothing, _) -> Right (Just ["A", "1"])
    Right (Just bsM, _) ->
      case checkAllBsMMoves bsM ('A', 1) of
        Right (c, i) -> Right (Just [[c], show i])
        Left err1 ->
          case checkAllBsMMoves (fromJust (bsMprev bsM)) ('A', 1) of
            Right (c, i) -> Right (Just [[c], show i])
            Left err2 -> Left err1

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
Check if with this coordinate, same player has any spots.
-}
checkBsMMove :: BattleshipsMsg -> (Char, Int) -> Bool
checkBsMMove bsM (letter, number)
  | checkIfCoordConflicts bsM (letter, number) == True = True
  | isJust (bsMprev bsM) && isJust (bsMprev (fromJust (bsMprev bsM))) = checkBsMMove (fromJust (bsMprev (fromJust (bsMprev bsM)))) (letter, number)
  | True = False

{-
Iterate through all coordinates for 1 player
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

{-
Start parsing here. Does all the job.
-}
parseSingleMove :: String -> Either String (Maybe BattleshipsMsg, String)
parseSingleMove (msg) =
  case getCoordinates msg of
    Left e1 -> Left e1
    Right (Just (letter, number), restAfterCoords) ->
      case getPrevious restAfterCoords of
        Left e2 -> Left e2
        Right (prevBsM, restAfterPrev) ->
          case getShotResult restAfterPrev of
            Left e3 -> Left e3
            Right (result, restAfterResult) -> Right (Just BattleshipsMsg {bsMcoord = Just (letter, number), bsMresult = result, bsMprev = prevBsM}, restAfterResult)
    Right (Nothing, restAfterCoords) ->
      case getPrevious restAfterCoords of
        Left e2 -> Left e2
        Right (prevBsM, restAfterPrev) ->
          case getShotResult restAfterPrev of
            Left e3 -> Left e3
            Right (result, restAfterResult) -> Right (Just BattleshipsMsg {bsMcoord = Nothing, bsMresult = result, bsMprev = prevBsM}, restAfterResult)

{-
Parses coordinates.
-}
getCoordinates :: String -> Either String (Maybe (Char, Int), String)
getCoordinates ('d':'5':':':'c':'o':'o':'r':'d':'d':'1':':':'1':'1':':':letter:'1':':':'2':'2':':':digit1:digit2:'e':rest)
  | isLetter letter == False = Left $ "Coordinate invalid, letter expected, remainder: " ++ rest
  | isDigit digit1  == False = Left $ "Coordinate invalid, digit expected, remainder: " ++ rest
  | isDigit digit2  == False = Left $ "Coordinate invalid, digit expected, remainder: " ++ rest
  | True = Right (Just (letter, read [digit1, digit2]), rest)
getCoordinates ('d':'5':':':'c':'o':'o':'r':'d':'d':'1':':':'1':'1':':':letter:'1':':':'2':'1':':':digit:'e':rest)
  | isLetter letter == False = Left $ "Coordinate invalid, letter expected, remainder: " ++ rest
  | isDigit digit  == False = Left $ "Coordinate invalid, digit expected, remainder: " ++ rest
  | True = Right (Just (letter, digitToInt digit), rest)
getCoordinates ('d':'5':':':'c':'o':'o':'r':'d':'d':'e':rest) = Right (Nothing, rest)
getCoordinates errorRemainder = Left $ "Coordinate invalid, unexpected symbols, while parsing: " ++ errorRemainder

{-
Parses shot results
-}
getShotResult :: String -> Either String (Maybe Bool, String)
getShotResult ('6':':':'r':'e':'s':'u':'l':'t':'4':':':'M':'I':'S':'S':'e':rest) =
  Right (Just False, rest)
getShotResult ('6':':':'r':'e':'s':'u':'l':'t':'3':':':'H':'I':'T':'e':rest) =
  Right (Just True, rest)
getShotResult "" =
  Right (Nothing, "")
getShotResult errorRemainder = Left $ "Result invalid, while parsing: " ++ errorRemainder

{-
Parses previous shots (calls "parseSingleMove")
-}
getPrevious :: String -> Either String (Maybe BattleshipsMsg, String)
getPrevious ('4':':':'p':'r':'e':'v':'d':'e':rest) = Right (Nothing, rest) -- d...e
getPrevious ('4':':':'p':'r':'e':'v':rest) = parseSingleMove rest
getPrevious ('e':rest) = Right (Nothing, rest)
getPrevious errorRemainder = Left $ "Previous entry invalid, while parsing: " ++ errorRemainder
