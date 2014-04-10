import Graphics.Collage as Collage

--Represent each square of the game
type GridSquare = {contents: Int, x:Int, y:Int}

--The whole game is just the list of squares
type Grid = [GridSquare]

--Convert the list of squares to a form to draw
drawGrid : Grid -> Form
drawGrid grid = let
    gridForms = map drawSquare grid
  in Collage.group gridForms

--
drawSquare : GridSquare -> Form
drawSquare square = let
    rawSquare = Collage.filled red <| Collage.square 1
    numElem = Collage.toForm <| plainText square.contents
    completeSquare = Collage.group [rawSquare, numElem]
  in Collage.move (toFloat square.x, toFloat square.y) completeSquare
  
  
mainGrid = constant <| [{contents=2, x=3, y=3},{contents=2, x=1, y=2}]  

main = let
    gameForm = lift (() . (Collage.scale 10) . drawGrid) mainGrid
    formList = lift (\x -> [x]) gameForm
   in lift (collage 100 100 ) formList