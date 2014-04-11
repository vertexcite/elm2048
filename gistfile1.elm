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

data Input = Move KeyMove [(Int, Int)] | NoInput

--Get the color for a particular number
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

scaleForNumber n = if
  | n > 1000 -> 1/60.0
  | n > 100 -> 1/30.0
  | n > 10 -> 1/20.0
  | otherwise -> 1/15.0

--Apply a function 4 times, useful for shifting
apply4 f = f . f . f . f

--Get the square at a given position
squareAt : Grid -> (Int, Int) -> Maybe GridSquare
{-
squareAt grid (x,y) = case filter (\sq -> sq.x == x && sq.y == y) grid of
  [] -> Nothing
  [sq] -> Just sq
  --(sq :: _) -> Just sq --TODO get rid of this case
  -}
  
squareAt grid (x,y) = case grid of
  [] -> Nothing
  (h::t) -> if h.x == x && h.y == y
    then Just h
    else squareAt t (x,y)
  
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

--Convert the list of squares to a form to draw
drawGrid : Grid -> Form
drawGrid grid = let
    gridForms = map drawSquare grid
    background =  Collage.move (2.5, 2.5) <| Collage.filled black <| Collage.square 4 
  in Collage.group <| [background]++gridForms 

--Filter squares in a given row or column
inRow : Int -> GridSquare -> Bool
inRow row sq = sq.y == row

inCol : Int -> GridSquare -> Bool
inCol col sq = sq.x == col

--Functions to sort elements from top to bottom, bottom to top, etc
--Useful for shifting elements in the right order
sortUp : Grid -> Grid
sortUp = sortBy (\sq -> sq.y)

sortDown = sortBy (\sq -> -1*sq.y)

sortLeft = sortBy (\sq -> -1*sq.x)

sortRight = sortBy (\sq ->  sq.x)

--If there's an empty spot above (below, etc.)
--Shift the given square into it, otherwise put it in its original place
--Takes in a "partial" grid of squares above (below, etc.) already placed
shiftSquareUp :  GridSquare -> Grid -> Grid
shiftSquareUp sq grid = 
  if sq.y == 4 
    then (sq :: grid)
    else case squareAt grid (sq.x, sq.y+1) of
      Nothing -> ({sq | y <- sq.y + 1} :: grid)
      _ -> (sq :: grid)
      
shiftSquareDown :  GridSquare -> Grid -> Grid
shiftSquareDown sq grid = 
  if sq.y == 1 
    then (sq :: grid)
    else case squareAt grid (sq.x, sq.y-1) of
      Nothing -> ({sq | y <- sq.y - 1} :: grid)
      _ -> (sq :: grid)
    
shiftSquareLeft :  GridSquare -> Grid -> Grid
shiftSquareLeft sq grid = 
  if sq.x == 1
    then (sq :: grid)
    else case squareAt grid (sq.x-1, sq.y) of
      Nothing -> ({sq | x <- sq.x - 1} :: grid)
      _ -> (sq :: grid)


shiftSquareRight :  GridSquare -> Grid -> Grid
shiftSquareRight sq grid = 
  if sq.x == 4 
    then (sq :: grid)
    else case squareAt grid (sq.x+1, sq.y) of
      Nothing -> ({sq | x <- sq.x + 1} :: grid)
      _ -> (sq :: grid)

--Functions to shift the squares for each time the player moves
--To move down, a square moves to the position in the grid where 
--Except when squares get combined
--Similar math is performed for left, right, etc.

shift : (GridSquare -> Grid -> Grid) -> (Grid -> Grid) -> Grid -> Grid
shift shiftFun sortFun grid = let
    shiftFold = (foldr shiftFun []) . sortFun
  in (apply4 shiftFold) grid --apply 4 times, move as far as can

shiftUp = shift shiftSquareUp sortUp

shiftDown = shift shiftSquareDown sortDown

shiftLeft = shift shiftSquareLeft sortLeft

shiftRight = shift shiftSquareRight sortRight

--Functions to look at a given square, and see if it can be merged with
--the square above (below, left of, right of) it

mergeSquareUp : GridSquare -> Grid -> Grid
mergeSquareUp sq grid = case squareAt grid (sq.x, sq.y+1) of
  Nothing -> (sq::grid)
  Just adj -> 
    if adj.contents == sq.contents
      then doubleSquare (sq.x, sq.y+1) grid
      else (sq::grid)

mergeSquareDown : GridSquare -> Grid -> Grid
mergeSquareDown sq grid = case squareAt grid (sq.x, sq.y-1) of
  Nothing -> (sq::grid)
  Just adj -> 
    if adj.contents == sq.contents
      then doubleSquare (sq.x, sq.y-1) grid
      else (sq::grid)
      
mergeSquareLeft : GridSquare -> Grid -> Grid
mergeSquareLeft sq grid = case squareAt grid (sq.x-1, sq.y) of
  Nothing -> (sq::grid)
  Just adj -> 
    if adj.contents == sq.contents
      then doubleSquare (sq.x-1, sq.y) grid
      else (sq::grid)
      
mergeSquareRight : GridSquare -> Grid -> Grid
mergeSquareRight sq grid = case squareAt grid (sq.x+1, sq.y) of
  Nothing -> (sq::grid)
  Just adj -> 
    if adj.contents == sq.contents
      then doubleSquare (sq.x+1, sq.y) grid
      else (sq::grid)

--Apply the merges to tiles in the correct order
applyInOrder mergeFun sortFun = (foldl mergeFun []) . sortFun 

mergeUp = applyInOrder mergeSquareUp sortDown

mergeDown = applyInOrder mergeSquareDown sortUp


mergeLeft = applyInOrder mergeSquareLeft sortRight


mergeRight = applyInOrder mergeSquareRight sortLeft


--In a list of tiles, find the first free tile, if any
firstFree : Grid -> [(Int, Int)] -> Maybe (Int, Int)
firstFree grid lst = case lst of
  [] -> Nothing
  (h::t) -> case squareAt grid h of
    Nothing -> Just h
    _ -> firstFree grid t


--Draw an individual square, and translate it into the right position
drawSquare : GridSquare -> Form
drawSquare square = let
    rawSquare = Collage.filled (colorFor square.contents) <| Collage.square 1
    numElem = Collage.scale (scaleForNumber square.contents)<| Collage.toForm <| plainText <| show square.contents
    completeSquare = Collage.group [rawSquare, numElem]
  in Collage.move (toFloat square.x, toFloat square.y) completeSquare
  

updateGameState : Input -> GameState -> GameState
updateGameState input gs = case (input, gs) of
  (Move move lst, Playing grid) -> let
      updatedGrid = 
        if move.x == 1
        then shiftRight <| mergeRight <| shiftRight grid
        else if move.x == -1
        then  shiftLeft <| shiftLeft <| mergeLeft <| shiftLeft grid
        else if move.y == -1
        then  shiftDown <| mergeDown <| shiftDown grid
        else if move.y == 1
        then  shiftUp <| mergeUp <| shiftUp grid
        else grid
    in case (firstFree updatedGrid lst, move.x == 0 && move.y == 0) of
      (_, True) -> gs
      (Just (x,y), False) -> Playing ({contents=2, x=x,y=y}::  updatedGrid)
      (Nothing, False) -> GameLost updatedGrid --TODO end game
  _ -> gs
    
allTiles = [(1,1), (1,2), (1,3), (1,4), (2,1), (2,2), (2,3), (2,4),
  (3,1), (3,2), (3,3), (3,4), (4,1), (4,2), (4,3), (4,4)]

startState =  Playing [{contents=2, x=1, y=4},{contents=2, x=1, y=3}]

drawGame gs = case gs of
  Playing grid -> drawGrid grid
  GameLost _ -> Collage.filled blue <| Collage.square 1000

keyInput = let
    randFlags = combine <| map (\_ -> Random.range 0 1 Keyboard.wasd) [1..16]
    randBools = lift (map (\x -> if x == 1 then True else False)) randFlags
    randomInsert (elem, front) lst = if front then (elem::lst) else (lst ++ [elem])
    elemFlags = lift (zip allTiles) randBools
    randomList = lift (foldr randomInsert []) elemFlags
    
    inputSignal = merge Keyboard.wasd Keyboard.arrows
    
  in lift2 Move inputSignal randomList

main = let
    gameState = foldp updateGameState startState keyInput
    rawFormList = lift (\x -> [drawGame x]) gameState
    
    scaleFor x y = (toFloat (min x y))/4.0
    
    makeTform (x,y) = TF.multiply (TF.translation (toFloat x/(-2.0)) (toFloat (y+100)/(-2.0) )) (TF.scale <| scaleFor x y)  
    tform = lift makeTform Window.dimensions
    gameForm = lift2 Collage.groupTransform tform rawFormList
    formList = lift (\x -> [x]) gameForm
    collageFunc = lift (\(x,y) -> collage x y) Window.dimensions
   in lift2 {-(asText . show) gameState-} (\f l -> f l) collageFunc  formList