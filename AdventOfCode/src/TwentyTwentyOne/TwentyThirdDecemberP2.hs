module TwentyTwentyOne.TwentyThirdDecemberP2 where

import Data.Bifunctor (second)
import Data.List (dropWhileEnd, transpose)
import Data.Map (Map)
import qualified Data.Map as M (delete, difference, elems, empty, filterWithKey, findMin, fromList, fromListWith, insert, insertWith, lookup, size, toList, (!))
import Data.Maybe (maybe, maybeToList)
import Data.Set (Set)
import qualified Data.Set as S (difference, empty, foldl, fromList, insert, intersection, map, member, null, singleton, toList, union, unions)
import qualified Data.Text as T (pack, splitOn, unpack)
import Data.Vector (Vector, (!), (//))
import qualified Data.Vector as V (findIndices, fromList, head, last, null, reverse, slice, tail, toList)
import Debug.Trace

data Anphipod = Amber | Bronze | Copper | Desert deriving (Eq, Ord)

data Room = A [Space] | B [Space] | C [Space] | D [Space] deriving (Eq, Ord)

data Space = Empty | Occupied Anphipod | RoomEntry Room deriving (Eq, Ord)

type Hallway = Vector Space

energy :: Anphipod -> Int
energy Amber = 1
energy Bronze = 10
energy Copper = 100
energy Desert = 1000

-- Moves ------------------------------------------------------

-- TODO:
-- DONE create a file (or do it at the end of this) that has all the steps of the optimal test case solution
-- parse it to get all the valid Hallways
-- Implement this https://en.wikipedia.org/wiki/A*_search_algorithm - the heuristic should be the difference with the full house, counting the type of anphipod
-- hardcode a test that: chains those steps, at each step search for the expected hallway, select it, run the next step. till the end
-- once the test works, extract the algorithm for the real input
-- Check the right answer on AoC

twentyThirdDecemberSolution2 :: Int
twentyThirdDecemberSolution2 = undefined -- solution inputHallway

test = undefined -- solution testHallway

-- Utilities -----------------------------------
getRoom h i = unsafeGetRoom $ h ! i

getRoomA :: Hallway -> Room
getRoomA h = getRoom h roomAIndex

roomAIndex = 2

getRoomB :: Hallway -> Room
getRoomB h = getRoom h roomBIndex

roomBIndex = 4

getRoomC :: Hallway -> Room
getRoomC h = getRoom h roomCIndex

roomCIndex = 6

getRoomD :: Hallway -> Room
getRoomD h = getRoom h roomDIndex

roomDIndex = 8

roomIndices = [roomAIndex, roomBIndex, roomCIndex, roomDIndex]

extractAnphipodFromRoom :: Room -> Maybe (Anphipod, Room, Int)
extractAnphipodFromRoom (A as)
  | (not . null) as = Just ((unsafeGetOccupied . head) as, A (tail as), [4, 3 .. 1] !! (length as - 1))
  | otherwise = Nothing
extractAnphipodFromRoom (B as)
  | (not . null) as = Just ((unsafeGetOccupied . head) as, B (tail as), [4, 3 .. 1] !! (length as - 1))
  | otherwise = Nothing
extractAnphipodFromRoom (C as)
  | (not . null) as = Just ((unsafeGetOccupied . head) as, C (tail as), [4, 3 .. 1] !! (length as - 1))
  | otherwise = Nothing
extractAnphipodFromRoom (D as)
  | (not . null) as = Just ((unsafeGetOccupied . head) as, D (tail as), [4, 3 .. 1] !! (length as - 1))
  | otherwise = Nothing

insertAnphipodInRoom :: Anphipod -> Room -> Maybe (Room, Int)
insertAnphipodInRoom a (A as)
  | length as < 4 = Just (A (Occupied a : as), [4, 3 .. 1] !! length as)
  | otherwise = Nothing
insertAnphipodInRoom a (B as)
  | length as < 4 = Just (B (Occupied a : as), [4, 3 .. 1] !! length as)
  | otherwise = Nothing
insertAnphipodInRoom a (C as)
  | length as < 4 = Just (C (Occupied a : as), [4, 3 .. 1] !! length as)
  | otherwise = Nothing
insertAnphipodInRoom a (D as)
  | length as < 4 = Just (D (Occupied a : as), [4, 3 .. 1] !! length as)
  | otherwise = Nothing

hallwayTakePath :: Hallway -> Int -> Int -> Vector Space
hallwayTakePath h start end = if start > end then V.reverse path else path
  where
    path = V.slice (min start end) (abs (end - start) + 1) h

hallwayValidatePath :: (Vector Space -> Bool) -> Hallway -> Int -> Int -> Bool
hallwayValidatePath validationF h start end = validationF $ hallwayTakePath h start end

hallwayValidatePathExitRoom room = hallwayValidatePath (pathValidatioConditionExitRoom room)

hallwayValidatePathEnterRoom anphi room = hallwayValidatePath (pathValidatioConditionEnterRoom anphi room)

pathValidatioConditionExitRoom :: Room -> Vector Space -> Bool
pathValidatioConditionExitRoom room path =
  isEmpty (V.last path)
    && isRoom (V.head path)
    && room' == room
    && not (isRoomDone room')
    && not (isGoodRoom room')
    && all (\s -> isEmpty s || isRoom s) path
  where
    room' = unsafeGetRoom (V.head path)

pathValidatioConditionEnterRoom :: Anphipod -> Room -> Vector Space -> Bool
pathValidatioConditionEnterRoom anphipod room path =
  isOccupied (V.head path)
    && unsafeGetOccupied (V.head path) == anphipod
    && isRoom (V.last path)
    && unsafeGetRoom (V.last path) == room
    && anphipodOwnRoom anphipod room
    && hasRoomSpace room
    && all (\s -> isEmpty s || isRoom s) (V.tail path)

unsafeGetRoom :: Space -> Room
unsafeGetRoom (RoomEntry r) = r

unsafeGetOccupied :: Space -> Anphipod
unsafeGetOccupied (Occupied a) = a

emptyIndices :: Hallway -> Vector Int
emptyIndices = V.findIndices isEmpty

occupiedIndices :: Hallway -> Vector Int
occupiedIndices = V.findIndices isOccupied

isEmpty :: Space -> Bool
isEmpty Empty = True
isEmpty _ = False

isOccupied :: Space -> Bool
isOccupied (Occupied _) = True
isOccupied _ = False

isRoom :: Space -> Bool
isRoom (RoomEntry _) = True
isRoom _ = False

isGoodRoom :: Room -> Bool
isGoodRoom (A as) = length as < 4 && length as > 0 && all (== (Occupied Amber)) as
isGoodRoom (B as) = length as < 4 && length as > 0 && all (== (Occupied Bronze)) as
isGoodRoom (C as) = length as < 4 && length as > 0 && all (== (Occupied Copper)) as
isGoodRoom (D as) = length as < 4 && length as > 0 && all (== (Occupied Desert)) as

anphipodOwnRoom :: Anphipod -> Room -> Bool
anphipodOwnRoom Amber (A _) = True
anphipodOwnRoom Bronze (B _) = True
anphipodOwnRoom Copper (C _) = True
anphipodOwnRoom Desert (D _) = True
anphipodOwnRoom _ _ = False

hasRoomSpace :: Room -> Bool
hasRoomSpace (A as) = length as < 4
hasRoomSpace (B as) = length as < 4
hasRoomSpace (C as) = length as < 4
hasRoomSpace (D as) = length as < 4

isRoomDone :: Room -> Bool
isRoomDone (A as) = length as == 4 && all (== (Occupied Amber)) as
isRoomDone (B as) = length as == 4 && all (== (Occupied Bronze)) as
isRoomDone (C as) = length as == 4 && all (== (Occupied Copper)) as
isRoomDone (D as) = length as == 4 && all (== (Occupied Desert)) as

allRoomsDone :: Hallway -> Bool
allRoomsDone h = isRoomDone (getRoomA h) && isRoomDone (getRoomB h) && isRoomDone (getRoomC h) && isRoomDone (getRoomD h)

input :: IO String
input = readFile "input/2021/23December.txt"

parseInput :: String -> Hallway
parseInput = (\l -> (//) ((V.fromList . fmap (const Empty)) (head l)) ((zip roomIndices . parseRooms) (tail l))) . filter (not . null) . fmap removeSpacesAndHash . lines
  where
    removeSpacesAndHash [] = []
    removeSpacesAndHash (x : xs) = if x == '#' || x == ' ' then removeSpacesAndHash xs else x : removeSpacesAndHash xs
    parseRooms =
      fmap
        ( \(room, as) ->
            if length as == 2
              then RoomEntry (setRoom room (head as) (as !! 1))
              else RoomEntry (setRoom' room as)
        )
        . zip
          [ setRoom' (A []) [Desert, Desert],
            setRoom' (B []) [Copper, Bronze],
            setRoom' (C []) [Bronze, Amber],
            setRoom' (D []) [Amber, Copper]
          ]
        . fmap (fmap (\x -> read [x] :: Anphipod))
        . transpose

setRoom :: Room -> Anphipod -> Anphipod -> Room
setRoom (A as) a d = A (Occupied a : as ++ [Occupied d])
setRoom (B as) a d = B (Occupied a : as ++ [Occupied d])
setRoom (C as) a d = C (Occupied a : as ++ [Occupied d])
setRoom (D as) a d = D (Occupied a : as ++ [Occupied d])

setRoom' :: Room -> [Anphipod] -> Room
setRoom' (A _) as = A (fmap Occupied as)
setRoom' (B _) as = B (fmap Occupied as)
setRoom' (C _) as = C (fmap Occupied as)
setRoom' (D _) as = D (fmap Occupied as)

inputTest :: String
inputTest =
  "#############\n\
  \#...........#\n\
  \###B#C#B#D###\n\
  \  #A#D#C#A#\n\
  \  #########"

--inputTest' :: IO [Hallway]
inputTest' = (fmap (parseInput . T.unpack) . T.splitOn (T.pack "\n\n") . T.pack) <$> readFile "input/2021/21DecemberTest.txt"

instance Show Space where
  show Empty = "."
  show (Occupied a) = "<" ++ show a ++ ">"
  show (RoomEntry r) = show r

instance Show Anphipod where
  show Amber = "A"
  show Bronze = "B"
  show Copper = "C"
  show Desert = "D"

instance Show Room where
  show (A as) = "A>" ++ show as
  show (B as) = "B>" ++ show as
  show (C as) = "C>" ++ show as
  show (D as) = "D>" ++ show as

instance Read Anphipod where
  readsPrec _ = readsAnphipod

readsAnphipod :: ReadS Anphipod
readsAnphipod ('A' : xs) = [(Amber, xs)]
readsAnphipod ('B' : xs) = [(Bronze, xs)]
readsAnphipod ('C' : xs) = [(Copper, xs)]
readsAnphipod ('D' : xs) = [(Desert, xs)]
readsAnphipod _ = []
