module Game2048 where

import Graphics.Collage as Collage
import Keyboard
import Random
import Transform2D as TF
import List exposing (..)
import Color exposing (rgb, green, black, grey)
import Graphics.Element exposing (show, color, centered, Element)
import Graphics.Collage exposing (Form)
import Text exposing (fromString)
import Signal exposing (..)

import Touch.Cardinal as Cardinal
import Touch.Gestures as Gestures

import Window

dim : Int
dim = 4

--Represent each square of the game
type alias GridSquare = {contents: Int, x:Int, y:Int}

--The whole game is just the list of squares
type alias Grid = List GridSquare

--Represent different states of play possible
type PlayState = Playing | GameWon | GameLost

type alias History = List Grid

type alias GameState = (PlayState, Grid, History) 

--Datatype wrapping all of our input signals together
--Has moves from the user, and a random ordering of squares
type alias Input = (Cardinal.Direction, Keyboard.KeyCode, Int)

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
     | otherwise -> f << apply (n-1) f

--Get the square at a given position in the grid
squareAt : Grid -> (Int, Int) -> Maybe GridSquare
squareAt grid (x,y) = case List.filter (\sq -> sq.x == x && sq.y == y) grid of
  [] -> Nothing
  [sq] -> Just sq

--Get square's coordinates as a tuple (x, y)
squareCoord : GridSquare -> (Int, Int)
squareCoord sq = (sq.x, sq.y)

--Returns true if the grid has a 2048
has2048 : Grid -> Bool
has2048 grid = case List.filter (\sq -> sq.contents >= 2048) grid of
    [] -> False
    _ -> True
  
--Delete a square from a given position, if it exists
deleteSquare : (Int, Int) -> Grid -> Grid
deleteSquare (x,y) = List.filter (\sq -> not <| sq.x == x && sq.y == y)

--Double the value of a given square
--Fails if the square does not exist
doubleSquare : (Int, Int) -> Grid -> Grid
doubleSquare coords grid = let
    sq = case squareAt grid coords of
      Just s -> s
    removedGrid = deleteSquare coords grid
  in ({sq | contents <- sq.contents*2} :: removedGrid)

type alias Direction = GridSquare -> GridSquare

flipy : GridSquare -> GridSquare
flipy sq =  {sq | y <- dim - sq.y + 1}

transpose : GridSquare -> GridSquare
transpose sq = {sq | y <- sq.x, x <- sq.y }

up : Direction
up = identity
-- up , sorting = \sq ->  sq.y, atEdge = \sq -> sq.y == dim }

down : Direction
down = flipy

right : Direction
right = transpose

-- Could have used left = flipy . transpose, but then would need to reverse the effect of left with a different transform.  This one is its own inverse.
left : Direction
left sq = {sq | y <- dim - sq.x + 1, x <- dim - sq.y + 1}

move : GridSquare -> GridSquare
move sq = {sq | y <- sq.y + 1}

atEdge: GridSquare -> Bool
atEdge sq = sq.y == dim

--If there's an empty spot in target space (i.e. above, below, etc.)
--Shift the given square into it, otherwise put it in its original place
--Takes in a "partial" grid of squares (above or below, etc.) already placed
shiftSquare :  GridSquare -> Grid -> Grid
shiftSquare sq grid = 
  if atEdge sq 
    then (sq :: grid)
    else case squareAt grid (squareCoord (move sq)) of
      Nothing -> (move sq :: grid)
      _ -> (sq :: grid)

--Functions to shift the squares for each time the player moves
--To move down, a square moves to the position in the grid where 
--Except when squares get combined
--Similar math is performed for left, right, etc.
shift : Grid -> Grid
shift grid = let
    shiftFold = (foldr (shiftSquare) []) << (sortBy (\sq -> sq.y))
  in (apply dim shiftFold) grid --apply dim times, move as far as can

--Functions to look at a given square, and see if it can be merged with
--the square above (below, left of, right of) it
--Note that we sort in the opposite order of shifting
--Since if we're moving up, the bottom square gets absorbed
mergeSquare : GridSquare -> Grid -> Grid
mergeSquare sq grid = case squareAt grid (squareCoord (move sq)) of
  Nothing -> (sq::grid)
  Just adj -> 
    if adj.contents == sq.contents
      then doubleSquare (squareCoord (move sq)) grid
      else (sq::grid)

--Apply the merges to tiles in the correct order
applyInOrder mergeFun sortFun = (foldl mergeFun []) << sortFun 

--Given a grid and a square, see if that square can be merged
--by moving up (down, left, right) and if so, do the merge
--And double the tile that absorbs it
mergeGrid = applyInOrder mergeSquare (sortBy (\sq -> -sq.y))


newTile : Grid -> Int -> Maybe GridSquare
newTile g n = let coord = case blanks g of
    [] -> Nothing
    bs -> Just <| nth1 (n % length bs) bs
  in case coord of 
    Nothing -> Nothing
    Just (x,y) -> Just {x=x, y=y, contents = 2 * (1 + (n % 2)) }

blanks : Grid -> List (Int,Int)
blanks g = let f x = case squareAt g x of 
    Nothing -> True
    _       -> False 
  in List.filter f allTiles

makeMove : Direction -> Grid -> Grid
makeMove dir grid = List.map dir <| shift <| mergeGrid <| shift <| List.map dir grid

direction : Cardinal.Direction -> Maybe Direction
direction move = 
  case move of
    Cardinal.Right -> Just right
    Cardinal.Left  -> Just left
    Cardinal.Up    -> Just up
    Cardinal.Down  -> Just down
    _ -> Nothing

--Given the current state of the game, and a change in input from the user
--Generate the new state of the game
coreUpdate : Maybe Direction -> Int -> GameState -> GameState
coreUpdate mdir n ((_, grid, hist) as gs) = 
  case mdir of 
    Nothing -> gs
    Just dir ->
      let
        penUpdatedGrid = makeMove dir grid
      in
        if sameGrid penUpdatedGrid grid then gs
        else if has2048 penUpdatedGrid && (not <| has2048 grid) then (GameWon, penUpdatedGrid, grid :: hist)
        else case (newTile penUpdatedGrid n) of
          Just t -> let updatedGrid = t::penUpdatedGrid
            in if canMove updatedGrid then (Playing, updatedGrid, grid :: hist) else (GameLost, updatedGrid, grid :: hist)
          Nothing -> if canMove grid then gs else (GameLost, penUpdatedGrid, grid :: hist)

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
    possibleGrids : List Grid
    possibleGrids = List.map (\x -> makeMove x grid) [up, down, left, right]
    live : Grid -> Bool
    live x = not (sameGrid grid x)
  in any live possibleGrids

--The different coordinates and value a new tile can have
--We randomly permute this to add new tiles to the board
allTiles : List (Int, Int)
allTiles = product [1..dim] [1..dim]

product : List a -> List b -> List (a,b)
product a b = concatMap (\x -> List.map (\y -> (x,y)) b) a

startGrid n = let 
    m1 = newTile [] n
    m2 = case m1 of 
      Just t1 -> newTile [t1] (n // 2)   
      _ -> Nothing
  in case (m1, m2) of
    (Nothing, _) -> []
    (Just t1, _) ->
      case m2 of 
        Just t2 -> [t1, t2]
        _ -> [t1]

startState n = (Playing, startGrid n, [])

--Extracts the nth element of a list, starting at 0
--Fails on empty lists
nth1 : Int -> List a -> a
nth1 n (h::t) = case n of
  0 -> h
  _ -> nth1 (n-1) t

-- --------------- Everything above this line is pure functional, below is FRP, rendering, or utils for those -------------------
offset : Float
offset = (toFloat dim)/2.0 + 0.5

--Draw an individual square, and translate it into the right position
--We assume each square is 1 "unit" wide, and positioned somewhere in [1,dim]*[1,dim]
drawSquare : GridSquare -> Form
drawSquare square = let
    rawSquare = Collage.filled (colorFor square.contents) <| Collage.square 0.9
    numElem = Collage.scale (scaleForNumber square.contents)<| Collage.toForm <| show square.contents
    completeSquare = Collage.group [rawSquare, numElem]
  in Collage.move (toFloat square.x, toFloat square.y) completeSquare
  
--Convert the list of squares to a Form to be drawn
drawGrid : Grid -> Form
drawGrid grid = let
    gridForms = List.map drawSquare grid
    background =  Collage.move (offset, offset) <| Collage.filled black <| Collage.square (toFloat dim) 
  in Collage.group <| [background]++gridForms 

drawMessageAndGrid : String -> Grid -> Form
drawMessageAndGrid message grid = let messageForm = Collage.move (offset, offset) <| Collage.scale (1/40.0) <| Collage.toForm <| color grey (centered <| fromString message )
    in Collage.group [drawGrid grid, messageForm ]

--Given a game state, convert it to a form to be drawn
drawGame : GameState -> Form
drawGame (playState, grid, _) = case playState of
  Playing -> drawGrid grid
  GameLost -> drawMessageAndGrid "GameOver" grid
  GameWon -> drawMessageAndGrid "Congratulations!" grid

arrows : Signal Cardinal.Direction
arrows = merge (Cardinal.fromArrows <~ Keyboard.arrows) Gestures.ray

input : Signal (Cardinal.Direction, Keyboard.KeyCode, Int)
input = (,) <~ arrows ~ Keyboard.presses

updateGameState : Input -> GameState -> GameState
updateGameState (move, control) ((_, grid, history) as state) =
  if | grid == [] -> (Playing, startGrid (generate Random.int 1 (2^31))), [])
     | control == 74 ->
          case history of 
            []    -> state
            g::gs -> (Playing, g, gs)
     | move == Cardinal.Nowhere -> state
     | otherwise -> coreUpdate (direction move) n state

port seed : Int

gameState : Signal GameState
gameState = foldp updateGameState (startState seed) input

rawFormList : Signal (List Form)
rawFormList = (\x -> [drawGame x]) <~ gameState

scaleFor : Int -> Int -> Float
scaleFor x y = (toFloat (min x y))/(2 * toFloat dim)

makeTform : (Int, Int) -> TF.Transform2D
makeTform (x,y) = TF.multiply (TF.translation (toFloat x/(-(toFloat dim))) (toFloat y/(-(toFloat dim)) )) (TF.scale <| scaleFor x y)  

tform : Signal TF.Transform2D
tform = makeTform <~ Window.dimensions

gameForm : Signal Form
gameForm = Collage.groupTransform <~ tform ~ rawFormList

formList : Signal (List Form)
formList = (\x -> [x]) <~ gameForm

collageFunc : Signal (List Form -> Element)
collageFunc = (\(x,y) -> Collage.collage x y) <~ Window.dimensions

--Wrap everything together: take the game state
--Get the form to draw it, transform it into screen coordinates
--Then convert it to an Element and draw it to the screen
main1 = collageFunc ~ formList

-- main2 = asText <~ gameState -- Useful for debugging
-- main = above <~ main1 ~ main2
main = main1
