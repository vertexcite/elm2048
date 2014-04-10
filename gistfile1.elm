import Graphics.Collage as Collage
import Keyboard
import Random

--Represent each square of the game
type GridSquare = {contents: Int, x:Int, y:Int}

--The whole game is just the list of squares
type Grid = [GridSquare]

--The move data given from the keyboard
type KeyMove = { x:Int, y:Int }

--Represent different states the came can be in
data GameState = Playing Grid | GameWon Grid | GameLost Grid

data Input = Move KeyMove [(Int, Int)] | NoInput

--Apply a function 4 times, useful for shifting
apply4 f = f . f . f . f

--Get the square at a given position
squareAt : Grid -> (Int, Int) -> Maybe GridSquare
squareAt grid (x,y) = case filter (\sq -> sq.x == x && sq.y == y) grid of
  [] -> Nothing
  [sq] -> Just sq
  (sq :: _) -> Just sq --TODO get rid of this case
  
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
  in Collage.group gridForms

--Filter squares in a given row or column
inRow : Int -> GridSquare -> Bool
inRow row sq = sq.y == row

inCol : Int -> GridSquare -> Bool
inCol col sq = sq.x == col

--Functions to sort elements from top to bottom, bottom to top, etc
--Useful for shifting elements in the right order
sortUp : Grid -> Grid
sortUp = sortBy (\sq -> -1*sq.y)

sortDown = sortBy (\sq -> sq.y)

sortLeft = sortBy (\sq -> sq.x)

sortRight = sortBy (\sq -> -1* sq.x)

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
  if sq.y == 0 
    then (sq :: grid)
    else case squareAt grid (sq.x, sq.y-1) of
      Nothing -> ({sq | y <- sq.y - 1} :: grid)
      _ -> (sq :: grid)
    
shiftSquareLeft :  GridSquare -> Grid -> Grid
shiftSquareLeft sq grid = 
  if sq.x == 0 
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

mergeUp = applyInOrder mergeSquareUp sortUp

mergeDown = applyInOrder mergeSquareDown sortDown


mergeLeft = applyInOrder mergeSquareLeft sortLeft


mergeRight = applyInOrder mergeSquareRight sortRight


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
    rawSquare = Collage.filled red <| Collage.square 1
    numElem = Collage.scale (1.0/15.0)<| Collage.toForm <| plainText <| show square.contents
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
    in case firstFree updatedGrid lst of
      Just (x,y) -> Playing ({contents=2, x=x,y=y}:: updatedGrid)
      Nothing -> GameLost [] --TODO end game
  _ -> gs
    
allTiles = [(1,1), (1,2), (1,3), (1,4), (2,1), (2,2), (2,3), (2,4),
  (3,1), (3,2), (3,3), (3,4), (4,1), (4,2), (4,3), (4,4)]

startState =  Playing [{contents=2, x=3, y=3},{contents=2, x=1, y=2}]

drawGame gs = case gs of
  Playing grid -> drawGrid grid
  GameLost _ -> Collage.filled blue <| Collage.square 1000

keyInput = let
    randFlags = combine <| map (\_ -> Random.range 0 1 Keyboard.wasd) [1..16]
    randBools = lift (map (\x -> if x == 1 then True else False)) randFlags
    randomInsert (elem, front) lst = if front then (elem::lst) else (lst ++ [elem])
    elemFlags = lift (zip allTiles) randBools
    randomList = lift (foldr randomInsert []) elemFlags
    
    
  in lift2 Move Keyboard.wasd randomList

main = let
    gameState = foldp updateGameState startState keyInput
    gameForm = lift ( (Collage.scale 10) . drawGame) gameState
    formList = lift (\x -> [x]) gameForm
   in lift (asText . show) gameState --lift (collage 100 100 ) formList