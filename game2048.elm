import Graphics.Collage as Collage
import Keyboard
import Random
import Transform2D as TF

import Window

dim : Int
dim = 4

--Represent each square of the game
type GridSquare = {contents: Int, x:Int, y:Int}

--The whole game is just the list of squares
type Grid = [GridSquare]

--The move data given from the keyboard
type KeyMove = { x:Int, y:Int }

--Represent different states of play possible
data PlayState = Playing | GameWon | GameLost

type History = [Grid]

type GameState = (PlayState, Grid, History) 

--Datatype wrapping all of our input signals together
--Has moves from the user, and a random ordering of squares
type Input = (KeyMove, Keyboard.KeyCode, Int)

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

--Apply a function n times
--We use this for shifting: we shift squares as much as we can
--By shifting them 1 square dim times
apply : Int -> (a -> a) -> (a -> a)
apply n f = 
  if | n == 0 -> f
     | otherwise -> f . apply (n-1) f

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
up    = { move = \sq -> {sq | y <- sq.y + 1}, sorting = \sq ->  sq.y, atEdge = \sq -> sq.y == dim }

down : Direction
down  = { move = \sq -> {sq | y <- sq.y - 1}, sorting = \sq -> -sq.y, atEdge = \sq -> sq.y == 1 }

left : Direction
left  = { move = \sq -> {sq | x <- sq.x - 1}, sorting = \sq -> -sq.x, atEdge = \sq -> sq.x == 1 }

right : Direction
right = { move = \sq -> {sq | x <- sq.x + 1}, sorting = \sq ->  sq.x, atEdge = \sq -> sq.x == dim }

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
  in (apply dim shiftFold) grid --apply dim times, move as far as can

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


newTile : Grid -> Int -> Maybe (Int, Int, Int)
newTile g n = let coord = case blanks g of
    [] -> Nothing
    bs -> Just <| nth1 (n `mod` length bs) bs
  in case coord of 
    Nothing -> Nothing
    Just (x,y) -> Just (x,y, 2 * (1 + (n `mod` 2)))

blanks : Grid -> [(Int,Int)]
blanks g = let f x = case squareAt g x of 
    Nothing -> True
    _       -> False 
  in filter f allTiles

makeMove : Direction -> Grid -> Grid
makeMove dir grid = (shift dir) <| (mergeGrid dir) <| (shift dir) grid

direction : KeyMove -> Direction
direction move =
  if      move.x ==  1 then right
  else if move.x == -1 then left
  else if move.y == -1 then down
  else up

--Given the current state of the game, and a change in input from the user
--Generate the new state of the game
coreUpdate : Direction -> Int -> GameState -> GameState
coreUpdate dir n ((_, grid, previous::olderHistory as history) as gs) = 
  let
    penUpdatedGrid = makeMove dir grid
  in
    if has2048 penUpdatedGrid then (GameWon, penUpdatedGrid, penUpdatedGrid :: history)
    else if sameGrid penUpdatedGrid grid then gs  
    else case (newTile penUpdatedGrid n) of
      Just (x,y,v) -> let updatedGrid = ({contents=v, x=x,y=y}::  penUpdatedGrid)
        in if canMove updatedGrid then (Playing, updatedGrid, updatedGrid :: history) else (GameLost, updatedGrid, history)
      Nothing -> if canMove grid then gs else (GameLost, penUpdatedGrid, penUpdatedGrid :: history)

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
allTiles : [(Int, Int)]
allTiles = product [1..dim] [1..dim]

product : [a] -> [b] -> [(a,b)]
product a b = concatMap (\x -> map (\y -> (x,y)) b) a

--For now, we always start with the same two tiles
--Will be made more sophisticated in future versions
startState =  (Playing, [{contents=2, x=1, y=dim},{contents=2, x=dim, y=1}], [])

--Extracts the nth element of a list, starting at 0
--Fails on empty lists
nth1 : Int -> [a] -> a
nth1 n (h::t) = case n of
  0 -> h
  _ -> nth1 (n-1) t

-- --------------- Everything above this line is pure functional, below is FRP, rendering, or utils for those -------------------
offset : Float
offset = (toFloat dim)/2.0 + 0.5

updateGameState : Input -> GameState -> GameState
updateGameState (move, control, n) ((_, _, previous::olderHistory as history) as gs) = 
  if control == 74 then (Playing, previous, olderHistory)
  else if move.x == 0 && move.y == 0 then gs
  else coreUpdate (direction move) n gs

--Draw an individual square, and translate it into the right position
--We assume each square is 1 "unit" wide, and positioned somewhere in [1,dim]*[1,dim]
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
    background =  Collage.move (offset, offset) <| Collage.filled black <| Collage.square (toFloat dim) 
  in Collage.group <| [background]++gridForms 

drawMessageAndGrid message grid = let messageForm = Collage.move (offset, offset) <| Collage.scale (1/40.0) <| Collage.toForm <| color grey (centered <| toText message )
    in Collage.group [drawGrid grid, messageForm ]

--Given a game state, convert it to a form to be drawn
drawGame (playState, grid, _) = case playState of
  Playing -> drawGrid grid
  GameLost -> drawMessageAndGrid "GameOver" grid
  GameWon -> drawMessageAndGrid "Congratulations!" grid

arrows = merge Keyboard.arrows Keyboard.wasd
    
input = (,,) <~ arrows ~ Keyboard.lastPressed ~ (Random.range 1 (2^31) arrows)

{-
gameState : Signal GameState
gameState = foldp updateGameState startState input

rawFormList = lift (\x -> [drawGame x]) gameState
scaleFor x y = (toFloat (min x y))/(2 * toFloat dim)
makeTform (x,y) = TF.multiply (TF.translation (toFloat x/(-(toFloat dim))) (toFloat y/(-(toFloat dim)) )) (TF.scale <| scaleFor x y)  
tform = lift makeTform Window.dimensions
gameForm = lift2 Collage.groupTransform tform rawFormList
formList = lift (\x -> [x]) gameForm
collageFunc = lift (\(x,y) -> collage x y) Window.dimensions
-}
--Wrap everything together: take the game state
--Get the form to draw it, transform it into screen coordinates
--Then convert it to an Element and draw it to the screen
main = asText <~ input {-} (\f l -> f l) <~ collageFunc ~ formList -}
