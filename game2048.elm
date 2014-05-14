--2048 in Elm
--Written by Joey Eremondi
--jmitdase@gmail.com
--Based on 2048 by Gabriele Cirulli
--which was based on 1024 by Veewo Studio
--and similar to Threes by Asher Vollme

{- Copyright (c) 2014, Joey Eremondi

All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.

    * Redistributions in binary form must reproduce the above
      copyright notice, this list of conditions and the following
      disclaimer in the documentation and/or other materials provided
      with the distribution.

    * Neither the name of Joey Eremondi nor the names of other
      contributors may be used to endorse or promote products derived
      from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
-}



import Graphics.Collage as Collage
import Keyboard
import Random
import Transform2D as TF

import Window

--Represent each square of the game
type GridSquare = {contents: Int, x:Int, y:Int}

--The whole game is just the list of squares
type Grid = [GridSquare]

--The move data given from the keyboard
type KeyMove = { x:Int, y:Int }

--Represent different states the came can be in
data GameState = Playing Grid | GameWon Grid | GameLost Grid

type CandidateList = [((Int, Int), Int)]
--Datatype wrapping all of our input signals together
--Has moves from the user, and a random ordering of squares
data Input = Move KeyMove CandidateList

--Get the color for a particular number's square
colorFor n = case n of
  2 -> rgb 238 238 218
  4 -> rgb 237 224 200
  8 -> rgb 242 177 121
  16 -> rgb 245 149 99
  32 -> rgb 246 130 96
  64 -> rgb 246 94 59
  128 -> rgb 237 207 114
  256 -> rgb 237 204 97
  512 -> rgb 237 201 82
  1024 -> rgb 237 197 63
  2048 -> rgb 237 194 46
  _ -> green

--Get the scale factor for a number
--More digits means bigger number
--We assume none have 5 digits
scaleForNumber n = if
  | n >= 1000 -> 1/60.0
  | n >= 100 -> 1/30.0
  | n >= 10 -> 1/20.0
  | otherwise -> 1/15.0

--Apply a function 4 times
--We use this for shifting: we shift squares as much as we can
--By shifting them 1 square 4 times
apply4 f = f . f . f . f

--Get the square at a given position in the grid
squareAt : Grid -> (Int, Int) -> Maybe GridSquare
squareAt grid (x,y) = case filter (\sq -> sq.x == x && sq.y == y) grid of
  [] -> Nothing
  [sq] -> Just sq

--Get square's coordinates as a tuple (x, y)
squareCoord : GridSquare -> (Int, Int)
squareCoord sq = (sq.x, sq.y)

--Returns true if the grid has a 2048
has2048 : Grid -> Bool
has2048 grid = case filter (\sq -> sq.contents >= 2048) grid of
    [] -> False
    _ -> True
  
--Delete a square from a given position, if it exists
deleteSquare : (Int, Int) -> Grid -> Grid
deleteSquare (x,y) = filter (\sq -> not <| sq.x == x && sq.y == y)

--Double the value of a given square
--Fails if the square does not exist
doubleSquare : (Int, Int) -> Grid -> Grid
doubleSquare coords grid = let
    sq = case squareAt grid coords of
      Just s -> s
    removedGrid = deleteSquare coords grid
  in ({sq | contents <- sq.contents*2} :: removedGrid)

type Direction = {move:GridSquare -> GridSquare, sorting:GridSquare -> Int, atEdge:GridSquare -> Bool}

up : Direction
up    = { move = \sq -> {sq | y <- sq.y + 1}, sorting = \sq ->  sq.y, atEdge = \sq -> sq.y == 4 }

down : Direction
down  = { move = \sq -> {sq | y <- sq.y - 1}, sorting = \sq -> -sq.y, atEdge = \sq -> sq.y == 1 }

left : Direction
left  = { move = \sq -> {sq | x <- sq.x - 1}, sorting = \sq -> -sq.x, atEdge = \sq -> sq.x == 1 }

right : Direction
right = { move = \sq -> {sq | x <- sq.x + 1}, sorting = \sq ->  sq.x, atEdge = \sq -> sq.x == 4 }

--If there's an empty spot in target space (i.e. above, below, etc.)
--Shift the given square into it, otherwise put it in its original place
--Takes in a "partial" grid of squares (above or below, etc.) already placed
shiftSquare :  Direction -> GridSquare -> Grid -> Grid
shiftSquare dir sq grid = 
  if dir.atEdge sq 
    then (sq :: grid)
    else case squareAt grid (squareCoord (dir.move sq)) of
      Nothing -> (dir.move sq :: grid)
      _ -> (sq :: grid)

--Functions to shift the squares for each time the player moves
--To move down, a square moves to the position in the grid where 
--Except when squares get combined
--Similar math is performed for left, right, etc.
shift : Direction -> Grid -> Grid
shift dir grid = let
    shiftFold = (foldr (shiftSquare dir) []) . (sortBy dir.sorting)
  in (apply4 shiftFold) grid --apply 4 times, move as far as can

--Functions to look at a given square, and see if it can be merged with
--the square above (below, left of, right of) it
--Note that we sort in the opposite order of shifting
--Since if we're moving up, the bottom square gets absorbed
mergeSquare : Direction -> GridSquare -> Grid -> Grid
mergeSquare dir sq grid = case squareAt grid (squareCoord (dir.move sq)) of
  Nothing -> (sq::grid)
  Just adj -> 
    if adj.contents == sq.contents
      then doubleSquare (squareCoord (dir.move sq)) grid
      else (sq::grid)

--Apply the merges to tiles in the correct order
applyInOrder mergeFun sortFun = (foldl mergeFun []) . sortFun 

--Given a grid and a square, see if that square can be merged
--by moving up (down, left, right) and if so, do the merge
--And double the tile that absorbs it
mergeGrid dir = applyInOrder (mergeSquare dir) (sortBy <| (\x -> -x) . dir.sorting )

--Given a list of tiles, find the first free tile, if any
--Used for placing random elements
firstFree : Grid -> [((Int, Int), Int)] -> Maybe (Int, Int, Int)
firstFree grid lst = case lst of
  [] -> Nothing
  (((x,y),v)::t) -> case squareAt grid (x,y) of
    Nothing -> Just (x,y,v)
    _ -> firstFree grid t

makeMove : Direction -> Grid -> Grid
makeMove dir grid = (shift dir) <| (mergeGrid dir) <| (shift dir) grid

--Given the current state of the game, and a change in input from the user
--Generate the new state of the game
updateGameState : Input -> GameState -> GameState
updateGameState (Move move lst) (Playing grid as gs) = case move.x == 0 && move.y == 0 of
  True -> gs
  _    -> 
    let
      dir =  
        if      move.x ==  1 then right
        else if move.x == -1 then left
        else if move.y == -1 then down
        else up
      penUpdatedGrid = makeMove dir grid
    in
      if has2048 penUpdatedGrid then GameWon penUpdatedGrid
      else case (firstFree penUpdatedGrid lst) of
        Just (x,y,v) -> 
          if sameGrid penUpdatedGrid grid then gs 
          else let updatedGrid = ({contents=v, x=x,y=y}::  penUpdatedGrid)
          in if canMove updatedGrid then Playing updatedGrid else GameLost updatedGrid
        Nothing    -> if canMove grid then gs else GameLost penUpdatedGrid


sameGrid : Grid -> Grid -> Bool
sameGrid g1 g2 =
  if length g1 /= length g2 then False else
    let 
      hasMatchingSquareInGrid1 s2 = case squareAt g1 (squareCoord s2) of
        Nothing -> False
        Just s1 -> s1.contents == s2.contents
    in all hasMatchingSquareInGrid1 g2

canMove : Grid -> Bool
canMove grid =  let
    possibleGrids : [Grid]
    possibleGrids = map (\x -> makeMove x grid) [up, down, left, right]
    live : Grid -> Bool
    live x = not (sameGrid grid x)
  in any live possibleGrids

--The different coordinates and value a new tile can have
--We randomly permute this to add new tiles to the board
allTiles : CandidateList
allTiles = product (product [1..4] [1..4]) [2,4]

product : [a] -> [b] -> [(a,b)]
product a b = concatMap (\x -> map (\y -> (x,y)) b) a

--For now, we always start with the same two tiles
--Will be made more sophisticated in future versions
startState =  Playing [{contents=2, x=1, y=4},{contents=2, x=1, y=3}]

--Extracts the nth element of a list, starting at 1
--Fails on empty lists
nth1 : Int -> [a] -> (a,[a])
nth1 n (h::t) = case n of
  1 -> (h,t)
  _ -> let 
      (nth, tailLeftOver) = nth1 (n-1) t
    in (nth, h::tailLeftOver)

--Shuffle the elements of the given list, assuming we have n random numbers
--Not exceeding n, n-1, etc.
shuffle : CandidateList -> [Int] -> CandidateList
shuffle lst randNums = let
    shuffleStep indexToAdd (elemsToAdd, listSoFar) = let
        (nextElem, leftOver) = nth1 indexToAdd elemsToAdd
      in (leftOver, nextElem::listSoFar)
  in snd <| foldr shuffleStep (lst, []) randNums

-- --------------- Everything above this line is pure functional, below is FRP -------------------

--Draw an individual square, and translate it into the right position
--We assume each square is 1 "unit" wide, and positioned somewhere in [1,4]*[1,4]
drawSquare : GridSquare -> Form
drawSquare square = let
    rawSquare = Collage.filled (colorFor square.contents) <| Collage.square 1
    numElem = Collage.scale (scaleForNumber square.contents)<| Collage.toForm <| plainText <| show square.contents
    completeSquare = Collage.group [rawSquare, numElem]
  in Collage.move (toFloat square.x, toFloat square.y) completeSquare
  
--Convert the list of squares to a Form to be drawn
drawGrid : Grid -> Form
drawGrid grid = let
    gridForms = map drawSquare grid
    background =  Collage.move (2.5, 2.5) <| Collage.filled black <| Collage.square 4 
  in Collage.group <| [background]++gridForms 

--Given a game state, convert it to a form to be drawn
drawGame gs = case gs of
  Playing grid -> drawGrid grid
  GameLost grid -> let
      messageForm = Collage.move (2.5, 2.5) <| Collage.scale (1/40.0) <| Collage.toForm <| color grey (centered <| toText "Game Over" )
    in Collage.group [drawGrid grid, messageForm ]
  GameWon grid -> let
      messageForm = Collage.move (2.5, 2.5) <| Collage.scale (1/40.0) <| Collage.toForm <| color grey (centered <| toText "Congratulations")
    in Collage.group [drawGrid grid, messageForm ]



--Convert WASD and Arrow input from the user into our input data type
--Bundling it with a random permutations of the tiles each time
keyInput : Signal Input
keyInput = let
    count = length allTiles
    randNums : Signal [Int]
    randNums = combine <| map (\upper -> Random.range 1 upper Keyboard.wasd) [1..count]
    randomList : Signal CandidateList
    randomList = lift (shuffle allTiles) randNums
    inputSignal : Signal KeyMove
    inputSignal = merge Keyboard.wasd Keyboard.arrows

  in lift2 Move inputSignal randomList

--Wrap everything together: take the game state
--Get the form to draw it, transform it into screen coordinates
--Then convert it to an Element and draw it to the screen
main = let
    gameState = foldp updateGameState startState keyInput
    rawFormList = lift (\x -> [drawGame x]) gameState
    scaleFor x y = (toFloat (min x y))/8.0
    makeTform (x,y) = TF.multiply (TF.translation (toFloat x/(-4.0)) (toFloat y/(-4.0) )) (TF.scale <| scaleFor x y)  
    tform = lift makeTform Window.dimensions
    gameForm = lift2 Collage.groupTransform tform rawFormList
    formList = lift (\x -> [x]) gameForm
    collageFunc = lift (\(x,y) -> collage x y) Window.dimensions
   in lift2 {-(asText . show) gameState-} (\f l -> f l) collageFunc  formList