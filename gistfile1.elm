import Graphics.Collage as Collage
import Keyboard

--Represent each square of the game
type GridSquare = {contents: Int, x:Int, y:Int}

--The whole game is just the list of squares
type Grid = [GridSquare]

--The move data given from the keyboard
type KeyMove = { x:Int, y:Int }

--Represent different states the came can be in
data GameState = Playing Grid | GameWon Grid | GameLost Grid

data Input = Move KeyMove

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

--Functions to shift the squares for each time the player moves
--To move down, a square moves to the position in the grid where 
--Except when squares get combined
--Similar math is performed for left, right, etc.

shiftUp : Grid -> Grid
shiftUp = id

shiftDown : Grid -> Grid
shiftDown = id

shiftLeft : Grid -> Grid
shiftLeft = id

shiftRight : Grid -> Grid
shiftRight = id

--Draw an individual square, and translate it into the right position
drawSquare : GridSquare -> Form
drawSquare square = let
    rawSquare = Collage.filled red <| Collage.square 1
    numElem = Collage.scale (1.0/15.0)<| Collage.toForm <| plainText <| show square.contents
    completeSquare = Collage.group [rawSquare, numElem]
  in Collage.move (toFloat square.x, toFloat square.y) completeSquare
  

updateGameState : Input -> GameState -> GameState
updateGameState update gs = gs


mainGrid = constant <| [{contents=2, x=3, y=3},{contents=2, x=1, y=2}]  

main = let
    gameForm = lift ( (Collage.scale 10) . drawGrid) mainGrid
    formList = lift (\x -> [x]) gameForm
   in lift (collage 100 100 ) formList