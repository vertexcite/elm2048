Elm.Game2048 = Elm.Game2048 || {};
Elm.Game2048.make = function (_elm) {
   "use strict";
   _elm.Game2048 = _elm.Game2048 || {};
   if (_elm.Game2048.values)
   return _elm.Game2048.values;
   var _N = Elm.Native,
   _U = _N.Utils.make(_elm),
   _L = _N.List.make(_elm),
   _A = _N.Array.make(_elm),
   _E = _N.Error.make(_elm),
   $moduleName = "Game2048";
   var Basics = Elm.Basics.make(_elm);
   var Color = Elm.Color.make(_elm);
   var Graphics = Graphics || {};
   Graphics.Collage = Elm.Graphics.Collage.make(_elm);
   var Graphics = Graphics || {};
   Graphics.Element = Elm.Graphics.Element.make(_elm);
   var Keyboard = Elm.Keyboard.make(_elm);
   var List = Elm.List.make(_elm);
   var Maybe = Elm.Maybe.make(_elm);
   var Native = Native || {};
   Native.Json = Elm.Native.Json.make(_elm);
   var Native = Native || {};
   Native.Ports = Elm.Native.Ports.make(_elm);
   var Random = Elm.Random.make(_elm);
   var Signal = Elm.Signal.make(_elm);
   var String = Elm.String.make(_elm);
   var Text = Elm.Text.make(_elm);
   var Time = Elm.Time.make(_elm);
   var Touch = Touch || {};
   Touch.Cardinal = Elm.Touch.Cardinal.make(_elm);
   var Touch = Touch || {};
   Touch.Gestures = Elm.Touch.Gestures.make(_elm);
   var Transform2D = Elm.Transform2D.make(_elm);
   var Window = Elm.Window.make(_elm);
   var _op = {};
   var collageFunc = A2(Signal._op["<~"],
   function (_v0) {
      return function () {
         switch (_v0.ctor)
         {case "_Tuple2":
            return A2(Graphics.Collage.collage,
              _v0._0,
              _v0._1);}
         _E.Case($moduleName,
         "on line 309, column 26 to 37");
      }();
   },
   Window.dimensions);
   var seed = Native.Ports.portIn("seed",
   function (v) {
      return typeof v === "number" ? v : _E.raise("invalid input, expecting JSNumber but got " + v);
   });
   var arrows = A2(Signal.merge,
   A2(Signal._op["<~"],
   Touch.Cardinal.fromArrows,
   Keyboard.arrows),
   Touch.Gestures.ray);
   var input = A2(Signal._op["~"],
   A2(Signal._op["~"],
   A2(Signal._op["<~"],
   F3(function (v0,v1,v2) {
      return {ctor: "_Tuple3"
             ,_0: v0
             ,_1: v1
             ,_2: v2};
   }),
   arrows),
   Keyboard.lastPressed),
   A3(Random.range,
   1,
   Math.pow(2,31),
   arrows));
   var nth1 = F2(function (n,_v4) {
      return function () {
         switch (_v4.ctor)
         {case "::": return function () {
                 switch (n)
                 {case 0: return _v4._0;}
                 return A2(nth1,n - 1,_v4._1);
              }();}
         _E.Case($moduleName,
         "between lines 234 and 236");
      }();
   });
   var product = F2(function (a,
   b) {
      return A2(List.concatMap,
      function (x) {
         return A2(List.map,
         function (y) {
            return {ctor: "_Tuple2"
                   ,_0: x
                   ,_1: y};
         },
         b);
      },
      a);
   });
   var applyInOrder = F2(function (mergeFun,
   sortFun) {
      return function ($) {
         return A2(List.foldl,
         mergeFun,
         _L.fromArray([]))(sortFun($));
      };
   });
   var left = {_: {}
              ,atEdge: function (sq) {
                 return _U.eq(sq.x,1);
              }
              ,move: function (sq) {
                 return _U.replace([["x"
                                    ,sq.x - 1]],
                 sq);
              }
              ,sorting: function (sq) {
                 return 0 - sq.x;
              }};
   var down = {_: {}
              ,atEdge: function (sq) {
                 return _U.eq(sq.y,1);
              }
              ,move: function (sq) {
                 return _U.replace([["y"
                                    ,sq.y - 1]],
                 sq);
              }
              ,sorting: function (sq) {
                 return 0 - sq.y;
              }};
   var Direction = F3(function (a,
   b,
   c) {
      return {_: {}
             ,atEdge: c
             ,move: a
             ,sorting: b};
   });
   var deleteSquare = function (_v9) {
      return function () {
         switch (_v9.ctor)
         {case "_Tuple2":
            return List.filter(function (sq) {
                 return Basics.not(_U.eq(sq.x,
                 _v9._0) && _U.eq(sq.y,_v9._1));
              });}
         _E.Case($moduleName,
         "on line 83, column 22 to 66");
      }();
   };
   var has2048 = function (grid) {
      return function () {
         var _v13 = A2(List.filter,
         function (sq) {
            return _U.cmp(sq.contents,
            2048) > -1;
         },
         grid);
         switch (_v13.ctor)
         {case "[]": return false;}
         return true;
      }();
   };
   var squareCoord = function (sq) {
      return {ctor: "_Tuple2"
             ,_0: sq.x
             ,_1: sq.y};
   };
   var squareAt = F2(function (grid,
   _v14) {
      return function () {
         switch (_v14.ctor)
         {case "_Tuple2":
            return function () {
                 var _v18 = A2(List.filter,
                 function (sq) {
                    return _U.eq(sq.x,
                    _v14._0) && _U.eq(sq.y,_v14._1);
                 },
                 grid);
                 switch (_v18.ctor)
                 {case "::":
                    switch (_v18._1.ctor)
                      {case "[]":
                         return Maybe.Just(_v18._0);}
                      break;
                    case "[]":
                    return Maybe.Nothing;}
                 _E.Case($moduleName,
                 "between lines 67 and 69");
              }();}
         _E.Case($moduleName,
         "between lines 67 and 69");
      }();
   });
   var doubleSquare = F2(function (coords,
   grid) {
      return function () {
         var removedGrid = A2(deleteSquare,
         coords,
         grid);
         var sq = function () {
            var _v21 = A2(squareAt,
            grid,
            coords);
            switch (_v21.ctor)
            {case "Just": return _v21._0;}
            _E.Case($moduleName,
            "between lines 89 and 91");
         }();
         return {ctor: "::"
                ,_0: _U.replace([["contents"
                                 ,sq.contents * 2]],
                sq)
                ,_1: removedGrid};
      }();
   });
   var shiftSquare = F3(function (dir,
   sq,
   grid) {
      return dir.atEdge(sq) ? {ctor: "::"
                              ,_0: sq
                              ,_1: grid} : function () {
         var _v23 = A2(squareAt,
         grid,
         squareCoord(dir.move(sq)));
         switch (_v23.ctor)
         {case "Nothing":
            return {ctor: "::"
                   ,_0: dir.move(sq)
                   ,_1: grid};}
         return {ctor: "::"
                ,_0: sq
                ,_1: grid};
      }();
   });
   var mergeSquare = F3(function (dir,
   sq,
   grid) {
      return function () {
         var _v24 = A2(squareAt,
         grid,
         squareCoord(dir.move(sq)));
         switch (_v24.ctor)
         {case "Just":
            return _U.eq(_v24._0.contents,
              sq.contents) ? A2(doubleSquare,
              squareCoord(dir.move(sq)),
              grid) : {ctor: "::"
                      ,_0: sq
                      ,_1: grid};
            case "Nothing":
            return {ctor: "::"
                   ,_0: sq
                   ,_1: grid};}
         _E.Case($moduleName,
         "between lines 133 and 138");
      }();
   });
   var mergeGrid = function (dir) {
      return A2(applyInOrder,
      mergeSquare(dir),
      List.sortBy(function ($) {
         return function (x) {
            return 0 - x;
         }(dir.sorting($));
      }));
   };
   var sameGrid = F2(function (g1,
   g2) {
      return !_U.eq(List.length(g1),
      List.length(g2)) ? false : function () {
         var hasMatchingSquareInGrid1 = function (s2) {
            return function () {
               var _v26 = A2(squareAt,
               g1,
               squareCoord(s2));
               switch (_v26.ctor)
               {case "Just":
                  return _U.eq(_v26._0.contents,
                    s2.contents);
                  case "Nothing": return false;}
               _E.Case($moduleName,
               "between lines 196 and 199");
            }();
         };
         return A2(List.all,
         hasMatchingSquareInGrid1,
         g2);
      }();
   });
   var apply = F2(function (n,f) {
      return _U.eq(n,
      0) ? f : function ($) {
         return f(A2(apply,
         n - 1,
         f)($));
      };
   });
   var scaleForNumber = function (n) {
      return _U.cmp(n,
      1000) > -1 ? 1 / 60.0 : _U.cmp(n,
      100) > -1 ? 1 / 30.0 : _U.cmp(n,
      10) > -1 ? 1 / 20.0 : 1 / 15.0;
   };
   var colorFor = function (n) {
      return function () {
         switch (n)
         {case 2: return A3(Color.rgb,
              238,
              238,
              218);
            case 4: return A3(Color.rgb,
              237,
              224,
              200);
            case 8: return A3(Color.rgb,
              242,
              177,
              121);
            case 16: return A3(Color.rgb,
              245,
              149,
              99);
            case 32: return A3(Color.rgb,
              246,
              130,
              96);
            case 64: return A3(Color.rgb,
              246,
              94,
              59);
            case 128: return A3(Color.rgb,
              237,
              207,
              114);
            case 256: return A3(Color.rgb,
              237,
              204,
              97);
            case 512: return A3(Color.rgb,
              237,
              201,
              82);
            case 1024: return A3(Color.rgb,
              237,
              197,
              63);
            case 2048: return A3(Color.rgb,
              237,
              194,
              46);}
         return Color.green;
      }();
   };
   var drawSquare = function (square) {
      return function () {
         var numElem = Graphics.Collage.scale(scaleForNumber(square.contents))(Graphics.Collage.toForm(Text.plainText(String.show(square.contents))));
         var rawSquare = Graphics.Collage.filled(colorFor(square.contents))(Graphics.Collage.square(0.9));
         var completeSquare = Graphics.Collage.group(_L.fromArray([rawSquare
                                                                  ,numElem]));
         return A2(Graphics.Collage.move,
         {ctor: "_Tuple2"
         ,_0: Basics.toFloat(square.x)
         ,_1: Basics.toFloat(square.y)},
         completeSquare);
      }();
   };
   var GameLost = {ctor: "GameLost"};
   var GameWon = {ctor: "GameWon"};
   var Playing = {ctor: "Playing"};
   var GridSquare = F3(function (a,
   b,
   c) {
      return {_: {}
             ,contents: a
             ,x: b
             ,y: c};
   });
   var dim = 3;
   var up = {_: {}
            ,atEdge: function (sq) {
               return _U.eq(sq.y,dim);
            }
            ,move: function (sq) {
               return _U.replace([["y"
                                  ,sq.y + 1]],
               sq);
            }
            ,sorting: function (sq) {
               return sq.y;
            }};
   var right = {_: {}
               ,atEdge: function (sq) {
                  return _U.eq(sq.x,dim);
               }
               ,move: function (sq) {
                  return _U.replace([["x"
                                     ,sq.x + 1]],
                  sq);
               }
               ,sorting: function (sq) {
                  return sq.x;
               }};
   var direction = function (move) {
      return function () {
         switch (move.ctor)
         {case "Down":
            return Maybe.Just(down);
            case "Left":
            return Maybe.Just(left);
            case "Right":
            return Maybe.Just(right);
            case "Up":
            return Maybe.Just(up);}
         return Maybe.Nothing;
      }();
   };
   var shift = F2(function (dir,
   grid) {
      return function () {
         var shiftFold = function ($) {
            return A2(List.foldr,
            shiftSquare(dir),
            _L.fromArray([]))(List.sortBy(dir.sorting)($));
         };
         return A3(apply,
         dim,
         shiftFold,
         grid);
      }();
   });
   var makeMove = F2(function (dir,
   grid) {
      return shift(dir)(mergeGrid(dir)(A2(shift,
      dir,
      grid)));
   });
   var canMove = function (grid) {
      return function () {
         var live = function (x) {
            return Basics.not(A2(sameGrid,
            grid,
            x));
         };
         var possibleGrids = A2(List.map,
         function (x) {
            return A2(makeMove,x,grid);
         },
         _L.fromArray([up
                      ,down
                      ,left
                      ,right]));
         return A2(List.any,
         live,
         possibleGrids);
      }();
   };
   var allTiles = A2(product,
   _L.range(1,dim),
   _L.range(1,dim));
   var blanks = function (g) {
      return function () {
         var f = function (x) {
            return function () {
               var _v30 = A2(squareAt,g,x);
               switch (_v30.ctor)
               {case "Nothing": return true;}
               return false;
            }();
         };
         return A2(List.filter,
         f,
         allTiles);
      }();
   };
   var newTile = F2(function (g,
   n) {
      return function () {
         var coord = function () {
            var _v31 = blanks(g);
            switch (_v31.ctor)
            {case "[]":
               return Maybe.Nothing;}
            return Maybe.Just(A2(nth1,
            A2(Basics.mod,
            n,
            List.length(_v31)),
            _v31));
         }();
         return function () {
            switch (coord.ctor)
            {case "Just":
               switch (coord._0.ctor)
                 {case "_Tuple2":
                    return Maybe.Just({_: {}
                                      ,contents: 2 + 0 * 2 * (1 + A2(Basics.mod,
                                      n,
                                      2))
                                      ,x: coord._0._0
                                      ,y: coord._0._1});}
                 break;
               case "Nothing":
               return Maybe.Nothing;}
            _E.Case($moduleName,
            "between lines 153 and 155");
         }();
      }();
   });
   var coreUpdate = F3(function (mdir,
   n,
   _v36) {
      return function () {
         switch (_v36.ctor)
         {case "_Tuple3":
            return function () {
                 switch (mdir.ctor)
                 {case "Just":
                    return function () {
                         var penUpdatedGrid = A2(makeMove,
                         mdir._0,
                         _v36._1);
                         return A2(sameGrid,
                         penUpdatedGrid,
                         _v36._1) ? _v36 : has2048(penUpdatedGrid) && Basics.not(has2048(_v36._1)) ? {ctor: "_Tuple3"
                                                                                                     ,_0: GameWon
                                                                                                     ,_1: penUpdatedGrid
                                                                                                     ,_2: {ctor: "::"
                                                                                                          ,_0: _v36._1
                                                                                                          ,_1: _v36._2}} : function () {
                            var _v43 = A2(newTile,
                            penUpdatedGrid,
                            n);
                            switch (_v43.ctor)
                            {case "Just":
                               return function () {
                                    var updatedGrid = {ctor: "::"
                                                      ,_0: _v43._0
                                                      ,_1: penUpdatedGrid};
                                    return canMove(updatedGrid) ? {ctor: "_Tuple3"
                                                                  ,_0: Playing
                                                                  ,_1: updatedGrid
                                                                  ,_2: {ctor: "::"
                                                                       ,_0: _v36._1
                                                                       ,_1: _v36._2}} : {ctor: "_Tuple3"
                                                                                        ,_0: GameLost
                                                                                        ,_1: updatedGrid
                                                                                        ,_2: {ctor: "::"
                                                                                             ,_0: _v36._1
                                                                                             ,_1: _v36._2}};
                                 }();
                               case "Nothing":
                               return canMove(_v36._1) ? _v36 : {ctor: "_Tuple3"
                                                                ,_0: GameLost
                                                                ,_1: penUpdatedGrid
                                                                ,_2: {ctor: "::"
                                                                     ,_0: _v36._1
                                                                     ,_1: _v36._2}};}
                            _E.Case($moduleName,
                            "between lines 187 and 190");
                         }();
                      }();
                    case "Nothing": return _v36;}
                 _E.Case($moduleName,
                 "between lines 179 and 190");
              }();}
         _E.Case($moduleName,
         "between lines 179 and 190");
      }();
   });
   var startGrid = function (n) {
      return function () {
         var m1 = A2(newTile,
         _L.fromArray([]),
         n);
         var m2 = function () {
            switch (m1.ctor)
            {case "Just": return A2(newTile,
                 _L.fromArray([m1._0]),
                 n / 2 | 0);}
            return Maybe.Nothing;
         }();
         return function () {
            var _v47 = {ctor: "_Tuple2"
                       ,_0: m1
                       ,_1: m2};
            switch (_v47.ctor)
            {case "_Tuple2":
               switch (_v47._0.ctor)
                 {case "Just":
                    return function () {
                         switch (m2.ctor)
                         {case "Just":
                            return _L.fromArray([_v47._0._0
                                                ,m2._0]);}
                         return _L.fromArray([_v47._0._0]);
                      }();
                    case "Nothing":
                    return _L.fromArray([]);}
                 break;}
            _E.Case($moduleName,
            "between lines 222 and 227");
         }();
      }();
   };
   var startState = function (n) {
      return {ctor: "_Tuple3"
             ,_0: Playing
             ,_1: startGrid(n)
             ,_2: _L.fromArray([])};
   };
   var updateGameState = F2(function (_v53,
   _v54) {
      return function () {
         switch (_v54.ctor)
         {case "_Tuple3":
            return function () {
                 switch (_v53.ctor)
                 {case "_Tuple3":
                    return _U.eq(_v54._1,
                      _L.fromArray([])) ? {ctor: "_Tuple3"
                                          ,_0: Playing
                                          ,_1: startGrid(_v53._2)
                                          ,_2: _L.fromArray([])} : _U.eq(_v53._1,
                      74) ? function () {
                         switch (_v54._2.ctor)
                         {case "::":
                            return {ctor: "_Tuple3"
                                   ,_0: Playing
                                   ,_1: _v54._2._0
                                   ,_2: _v54._2._1};
                            case "[]": return _v54;}
                         _E.Case($moduleName,
                         "between lines 279 and 282");
                      }() : _U.eq(_v53._0,
                      Touch.Cardinal.Nowhere) ? _v54 : A3(coreUpdate,
                      direction(_v53._0),
                      _v53._2,
                      _v54);}
                 _E.Case($moduleName,
                 "between lines 277 and 283");
              }();}
         _E.Case($moduleName,
         "between lines 277 and 283");
      }();
   });
   var gameState = A3(Signal.foldp,
   updateGameState,
   startState(seed),
   input);
   var offset = Basics.toFloat(dim) / 2.0 + 0.5;
   var drawGrid = function (grid) {
      return function () {
         var background = Graphics.Collage.move({ctor: "_Tuple2"
                                                ,_0: offset
                                                ,_1: offset})(Graphics.Collage.filled(Color.black)(Graphics.Collage.square(Basics.toFloat(dim))));
         var gridForms = A2(List.map,
         drawSquare,
         grid);
         return Graphics.Collage.group(_L.append(_L.fromArray([background]),
         gridForms));
      }();
   };
   var drawMessageAndGrid = F2(function (message,
   grid) {
      return function () {
         var messageForm = Graphics.Collage.move({ctor: "_Tuple2"
                                                 ,_0: offset
                                                 ,_1: offset})(Graphics.Collage.scale(1 / 40.0)(Graphics.Collage.toForm(A2(Graphics.Element.color,
         Color.grey,
         Text.centered(Text.toText(message))))));
         return Graphics.Collage.group(_L.fromArray([drawGrid(grid)
                                                    ,messageForm]));
      }();
   });
   var drawGame = function (_v66) {
      return function () {
         switch (_v66.ctor)
         {case "_Tuple3":
            return function () {
                 switch (_v66._0.ctor)
                 {case "GameLost":
                    return A2(drawMessageAndGrid,
                      "GameOver",
                      _v66._1);
                    case "GameWon":
                    return A2(drawMessageAndGrid,
                      "Congratulations!",
                      _v66._1);
                    case "Playing":
                    return drawGrid(_v66._1);}
                 _E.Case($moduleName,
                 "between lines 264 and 267");
              }();}
         _E.Case($moduleName,
         "between lines 264 and 267");
      }();
   };
   var rawFormList = A2(Signal._op["<~"],
   function (x) {
      return _L.fromArray([drawGame(x)]);
   },
   gameState);
   var scaleFor = F2(function (x,
   y) {
      return Basics.toFloat(A2(Basics.min,
      x,
      y)) / (2 * Basics.toFloat(dim));
   });
   var makeTform = function (_v72) {
      return function () {
         switch (_v72.ctor)
         {case "_Tuple2":
            return A2(Transform2D.multiply,
              A2(Transform2D.translation,
              Basics.toFloat(_v72._0) / (0 - Basics.toFloat(dim)),
              Basics.toFloat(_v72._1) / (0 - Basics.toFloat(dim))),
              Transform2D.scale(A2(scaleFor,
              _v72._0,
              _v72._1)));}
         _E.Case($moduleName,
         "on line 297, column 19 to 132");
      }();
   };
   var tform = A2(Signal._op["<~"],
   makeTform,
   Window.dimensions);
   var gameForm = A2(Signal._op["~"],
   A2(Signal._op["<~"],
   Graphics.Collage.groupTransform,
   tform),
   rawFormList);
   var formList = A2(Signal._op["<~"],
   function (x) {
      return _L.fromArray([x]);
   },
   gameForm);
   var main1 = A2(Signal._op["~"],
   collageFunc,
   formList);
   var main = main1;
   _elm.Game2048.values = {_op: _op
                          ,dim: dim
                          ,colorFor: colorFor
                          ,scaleForNumber: scaleForNumber
                          ,apply: apply
                          ,squareAt: squareAt
                          ,squareCoord: squareCoord
                          ,has2048: has2048
                          ,deleteSquare: deleteSquare
                          ,doubleSquare: doubleSquare
                          ,up: up
                          ,down: down
                          ,left: left
                          ,right: right
                          ,shiftSquare: shiftSquare
                          ,shift: shift
                          ,mergeSquare: mergeSquare
                          ,applyInOrder: applyInOrder
                          ,mergeGrid: mergeGrid
                          ,newTile: newTile
                          ,blanks: blanks
                          ,makeMove: makeMove
                          ,direction: direction
                          ,coreUpdate: coreUpdate
                          ,sameGrid: sameGrid
                          ,canMove: canMove
                          ,allTiles: allTiles
                          ,product: product
                          ,startGrid: startGrid
                          ,startState: startState
                          ,nth1: nth1
                          ,offset: offset
                          ,drawSquare: drawSquare
                          ,drawGrid: drawGrid
                          ,drawMessageAndGrid: drawMessageAndGrid
                          ,drawGame: drawGame
                          ,arrows: arrows
                          ,input: input
                          ,updateGameState: updateGameState
                          ,gameState: gameState
                          ,rawFormList: rawFormList
                          ,scaleFor: scaleFor
                          ,makeTform: makeTform
                          ,tform: tform
                          ,gameForm: gameForm
                          ,formList: formList
                          ,collageFunc: collageFunc
                          ,main1: main1
                          ,main: main
                          ,Playing: Playing
                          ,GameWon: GameWon
                          ,GameLost: GameLost
                          ,GridSquare: GridSquare
                          ,Direction: Direction};
   return _elm.Game2048.values;
};Elm.Touch = Elm.Touch || {};
Elm.Touch.Gestures = Elm.Touch.Gestures || {};
Elm.Touch.Gestures.make = function (_elm) {
   "use strict";
   _elm.Touch = _elm.Touch || {};
   _elm.Touch.Gestures = _elm.Touch.Gestures || {};
   if (_elm.Touch.Gestures.values)
   return _elm.Touch.Gestures.values;
   var _N = Elm.Native,
   _U = _N.Utils.make(_elm),
   _L = _N.List.make(_elm),
   _A = _N.Array.make(_elm),
   _E = _N.Error.make(_elm),
   $moduleName = "Touch.Gestures";
   var Basics = Elm.Basics.make(_elm);
   var Color = Elm.Color.make(_elm);
   var Graphics = Graphics || {};
   Graphics.Collage = Elm.Graphics.Collage.make(_elm);
   var Graphics = Graphics || {};
   Graphics.Element = Elm.Graphics.Element.make(_elm);
   var List = Elm.List.make(_elm);
   var Maybe = Elm.Maybe.make(_elm);
   var Native = Native || {};
   Native.Json = Elm.Native.Json.make(_elm);
   var Native = Native || {};
   Native.Ports = Elm.Native.Ports.make(_elm);
   var Signal = Elm.Signal.make(_elm);
   var String = Elm.String.make(_elm);
   var Text = Elm.Text.make(_elm);
   var Time = Elm.Time.make(_elm);
   var Touch = Elm.Touch.make(_elm);
   var Touch = Touch || {};
   Touch.Cardinal = Elm.Touch.Cardinal.make(_elm);
   var Touch = Touch || {};
   Touch.Signal = Touch.Signal || {};
   Touch.Signal.Derived = Elm.Touch.Signal.Derived.make(_elm);
   var Touch = Touch || {};
   Touch.Swipe = Elm.Touch.Swipe.make(_elm);
   var Touch = Touch || {};
   Touch.Tap = Elm.Touch.Tap.make(_elm);
   var Touch = Touch || {};
   Touch.Types = Elm.Touch.Types.make(_elm);
   var Touch = Touch || {};
   Touch.Util = Elm.Touch.Util.make(_elm);
   var _op = {};
   var relativeImp = F2(function (_v0,
   _v1) {
      return function () {
         switch (_v1.ctor)
         {case "_Tuple2":
            return function () {
                 switch (_v0.ctor)
                 {case "_Tuple2":
                    return Touch.Cardinal.vector2ToCardinal(Touch.Util.lineSegToVector2({ctor: "_Tuple2"
                                                                                        ,_0: {ctor: "_Tuple2"
                                                                                             ,_0: _v0._0
                                                                                             ,_1: _v0._1}
                                                                                        ,_1: {ctor: "_Tuple2"
                                                                                             ,_0: _v1._0
                                                                                             ,_1: _v1._1}}));}
                 _E.Case($moduleName,
                 "on line 90, column 30 to 97");
              }();}
         _E.Case($moduleName,
         "on line 90, column 30 to 97");
      }();
   });
   var relativeWithin = F2(function (dis,
   _v8) {
      return function () {
         switch (_v8.ctor)
         {case "_Tuple2":
            return function () {
                 var cardinal = function (_v12) {
                    return function () {
                       return A2(relativeImp,
                       _v8,
                       {ctor: "_Tuple2"
                       ,_0: _v12.x
                       ,_1: _v12.y});
                    }();
                 };
                 var ok = function (_v14) {
                    return function () {
                       return _U.cmp(A2(Touch.Util.distance,
                       _v8,
                       {ctor: "_Tuple2"
                       ,_0: _v14.x
                       ,_1: _v14.y}),
                       dis) < 1;
                    }();
                 };
                 return A2(Signal._op["<~"],
                 cardinal,
                 A3(Signal.keepIf,
                 ok,
                 {_: {},x: 0,y: 0},
                 Touch.taps));
              }();}
         _E.Case($moduleName,
         "between lines 100 and 102");
      }();
   });
   var relative = function (fixed) {
      return A2(Signal._op["<~"],
      function ($) {
         return relativeImp(fixed)(function (_v16) {
            return function () {
               return {ctor: "_Tuple2"
                      ,_0: _v16.x
                      ,_1: _v16.y};
            }();
         }($));
      },
      Touch.taps);
   };
   var tap = A2(Signal._op["<~"],
   function (_v18) {
      return function () {
         return Touch.Tap.oneFinger(_L.fromArray([{ctor: "_Tuple2"
                                                  ,_0: _v18.x
                                                  ,_1: _v18.y}]));
      }();
   },
   Touch.taps);
   var NotDragging = {ctor: "NotDragging"};
   var DragJustFinished = function (a) {
      return {ctor: "DragJustFinished"
             ,_0: a};
   };
   var f = function (_v20) {
      return function () {
         switch (_v20.ctor)
         {case "_Tuple2":
            return function () {
                 switch (_v20._0.ctor)
                 {case "DragJustFinished":
                    return Touch.Cardinal.fromSwipe(_v20._0._0);}
                 return _L.fromArray([Touch.Cardinal.Nowhere]);
              }();}
         _E.Case($moduleName,
         "between lines 71 and 77");
      }();
   };
   var TouchJustFinished = {ctor: "TouchJustFinished"};
   var TouchJustStarted = {ctor: "TouchJustStarted"};
   var Dragging = {ctor: "Dragging"};
   var processTouchDragging = F2(function (ts,
   _v26) {
      return function () {
         switch (_v26.ctor)
         {case "_Tuple2":
            return function () {
                 var touching = _U.cmp(List.length(ts),
                 0) > 0;
                 return touching ? function () {
                    switch (_v26._0.ctor)
                    {case "DragJustFinished":
                       return {ctor: "_Tuple2"
                              ,_0: TouchJustStarted
                              ,_1: ts};
                       case "Dragging":
                       return {ctor: "_Tuple2"
                              ,_0: Dragging
                              ,_1: ts};
                       case "NotDragging":
                       return {ctor: "_Tuple2"
                              ,_0: TouchJustStarted
                              ,_1: ts};
                       case "TouchJustFinished":
                       return {ctor: "_Tuple2"
                              ,_0: TouchJustStarted
                              ,_1: ts};
                       case "TouchJustStarted":
                       return {ctor: "_Tuple2"
                              ,_0: Dragging
                              ,_1: ts};}
                    _E.Case($moduleName,
                    "between lines 46 and 52");
                 }() : function () {
                    switch (_v26._0.ctor)
                    {case "DragJustFinished":
                       return {ctor: "_Tuple2"
                              ,_0: NotDragging
                              ,_1: _L.fromArray([])};
                       case "Dragging":
                       return {ctor: "_Tuple2"
                              ,_0: DragJustFinished(Touch.Swipe.fromTouches(_v26._1))
                              ,_1: _L.fromArray([])};
                       case "NotDragging":
                       return {ctor: "_Tuple2"
                              ,_0: NotDragging
                              ,_1: _L.fromArray([])};
                       case "TouchJustFinished":
                       return {ctor: "_Tuple2"
                              ,_0: NotDragging
                              ,_1: _L.fromArray([])};
                       case "TouchJustStarted":
                       return {ctor: "_Tuple2"
                              ,_0: TouchJustFinished
                              ,_1: _L.fromArray([])};}
                    _E.Case($moduleName,
                    "between lines 53 and 59");
                 }();
              }();}
         _E.Case($moduleName,
         "between lines 42 and 59");
      }();
   });
   var touchDragState = A3(Signal.foldp,
   processTouchDragging,
   {ctor: "_Tuple2"
   ,_0: NotDragging
   ,_1: _L.fromArray([])},
   Touch.touches);
   var ray = A2(Signal._op["<~"],
   function ($) {
      return List.head(f($));
   },
   touchDragState);
   var swipePred = A2(Signal._op["<~"],
   function (ts) {
      return _U.eq(List.length(ts),
      0);
   },
   Touch.touches);
   var swipe = A2(Signal._op["<~"],
   Touch.Swipe.fromTouches,
   A3(Signal.keepWhen,
   swipePred,
   _L.fromArray([]),
   Touch.touches));
   var slide = function () {
      var ok = function (ts) {
         return Basics.not(List.isEmpty(ts)) && Basics.not(Touch.Util.isTap(List.head(ts)));
      };
      return A2(Signal._op["<~"],
      Touch.Swipe.fromTouches,
      A3(Signal.keepIf,
      ok,
      _L.fromArray([]),
      Touch.touches));
   }();
   _elm.Touch.Gestures.values = {_op: _op
                                ,slide: slide
                                ,swipePred: swipePred
                                ,swipe: swipe
                                ,processTouchDragging: processTouchDragging
                                ,touchDragState: touchDragState
                                ,ray: ray
                                ,f: f
                                ,tap: tap
                                ,relative: relative
                                ,relativeImp: relativeImp
                                ,relativeWithin: relativeWithin
                                ,Dragging: Dragging
                                ,TouchJustStarted: TouchJustStarted
                                ,TouchJustFinished: TouchJustFinished
                                ,DragJustFinished: DragJustFinished
                                ,NotDragging: NotDragging};
   return _elm.Touch.Gestures.values;
};Elm.Touch = Elm.Touch || {};
Elm.Touch.Cardinal = Elm.Touch.Cardinal || {};
Elm.Touch.Cardinal.make = function (_elm) {
   "use strict";
   _elm.Touch = _elm.Touch || {};
   _elm.Touch.Cardinal = _elm.Touch.Cardinal || {};
   if (_elm.Touch.Cardinal.values)
   return _elm.Touch.Cardinal.values;
   var _N = Elm.Native,
   _U = _N.Utils.make(_elm),
   _L = _N.List.make(_elm),
   _A = _N.Array.make(_elm),
   _E = _N.Error.make(_elm),
   $moduleName = "Touch.Cardinal";
   var Basics = Elm.Basics.make(_elm);
   var Color = Elm.Color.make(_elm);
   var Graphics = Graphics || {};
   Graphics.Collage = Elm.Graphics.Collage.make(_elm);
   var Graphics = Graphics || {};
   Graphics.Element = Elm.Graphics.Element.make(_elm);
   var List = Elm.List.make(_elm);
   var Maybe = Elm.Maybe.make(_elm);
   var Native = Native || {};
   Native.Json = Elm.Native.Json.make(_elm);
   var Native = Native || {};
   Native.Ports = Elm.Native.Ports.make(_elm);
   var Signal = Elm.Signal.make(_elm);
   var String = Elm.String.make(_elm);
   var Text = Elm.Text.make(_elm);
   var Time = Elm.Time.make(_elm);
   var Touch = Touch || {};
   Touch.Types = Elm.Touch.Types.make(_elm);
   var Touch = Touch || {};
   Touch.Util = Elm.Touch.Util.make(_elm);
   var _op = {};
   var UpLeft = {ctor: "UpLeft"};
   var upLeft = UpLeft;
   var Left = {ctor: "Left"};
   var left = Left;
   var DownLeft = {ctor: "DownLeft"};
   var downLeft = DownLeft;
   var Down = {ctor: "Down"};
   var down = Down;
   var DownRight = {ctor: "DownRight"};
   var downRight = DownRight;
   var Right = {ctor: "Right"};
   var right = Right;
   var UpRight = {ctor: "UpRight"};
   var upRight = UpRight;
   var Up = {ctor: "Up"};
   var up = Up;
   var fromAngle = function (a) {
      return function () {
         var bw = F3(function (a,
         b1,
         b2) {
            return _U.cmp(a,
            b1) > -1 && _U.cmp(b2,a) > 0;
         });
         return A3(bw,
         a,
         (0 - Basics.pi) / 8,
         Basics.pi / 8) ? right : A3(bw,
         a,
         Basics.pi / 8,
         3 * Basics.pi / 8) ? upRight : A3(bw,
         a,
         3 * Basics.pi / 8,
         5 * Basics.pi / 8) ? up : A3(bw,
         a,
         5 * Basics.pi / 8,
         7 * Basics.pi / 8) ? upLeft : A3(bw,
         a,
         -3 * Basics.pi / 8,
         (0 - Basics.pi) / 8) ? downRight : A3(bw,
         a,
         -5 * Basics.pi / 8,
         -3 * Basics.pi / 8) ? down : A3(bw,
         a,
         -7 * Basics.pi / 8,
         -5 * Basics.pi / 8) ? downLeft : left;
      }();
   };
   var fromSwipe = function (_v0) {
      return function () {
         switch (_v0.ctor)
         {case "Swipe":
            return A2(List.map,
              function ($) {
                 return fromAngle(Touch.Util.lineSegAngle($));
              },
              _v0._1);}
         _E.Case($moduleName,
         "on line 29, column 32 to 71");
      }();
   };
   var vector2ToCardinal = function (_v4) {
      return function () {
         switch (_v4.ctor)
         {case "_Tuple2":
            return fromAngle(A2(Basics.atan2,
              _v4._0,
              _v4._1));}
         _E.Case($moduleName,
         "on line 32, column 27 to 49");
      }();
   };
   var Nowhere = {ctor: "Nowhere"};
   var nowhere = Nowhere;
   var fromArrows = function (_v8) {
      return function () {
         return _U.eq(_v8.x,
         1) && _U.eq(_v8.y,
         0) ? right : _U.eq(_v8.x,
         1) && _U.eq(_v8.y,
         1) ? upRight : _U.eq(_v8.x,
         0) && _U.eq(_v8.y,
         1) ? up : _U.eq(_v8.x,
         -1) && _U.eq(_v8.y,
         1) ? upLeft : _U.eq(_v8.x,
         1) && _U.eq(_v8.y,
         -1) ? downRight : _U.eq(_v8.x,
         0) && _U.eq(_v8.y,
         -1) ? down : _U.eq(_v8.x,
         -1) && _U.eq(_v8.y,
         -1) ? downLeft : _U.eq(_v8.x,
         -1) && _U.eq(_v8.y,
         0) ? left : nowhere;
      }();
   };
   _elm.Touch.Cardinal.values = {_op: _op
                                ,fromSwipe: fromSwipe
                                ,vector2ToCardinal: vector2ToCardinal
                                ,fromAngle: fromAngle
                                ,fromArrows: fromArrows
                                ,nowhere: nowhere
                                ,up: up
                                ,upRight: upRight
                                ,right: right
                                ,downRight: downRight
                                ,down: down
                                ,downLeft: downLeft
                                ,left: left
                                ,upLeft: upLeft
                                ,Nowhere: Nowhere
                                ,Up: Up
                                ,UpRight: UpRight
                                ,Right: Right
                                ,DownRight: DownRight
                                ,Down: Down
                                ,DownLeft: DownLeft
                                ,Left: Left
                                ,UpLeft: UpLeft};
   return _elm.Touch.Cardinal.values;
};Elm.Touch = Elm.Touch || {};
Elm.Touch.Signal = Elm.Touch.Signal || {};
Elm.Touch.Signal.Derived = Elm.Touch.Signal.Derived || {};
Elm.Touch.Signal.Derived.make = function (_elm) {
   "use strict";
   _elm.Touch = _elm.Touch || {};
   _elm.Touch.Signal = _elm.Touch.Signal || {};
   _elm.Touch.Signal.Derived = _elm.Touch.Signal.Derived || {};
   if (_elm.Touch.Signal.Derived.values)
   return _elm.Touch.Signal.Derived.values;
   var _N = Elm.Native,
   _U = _N.Utils.make(_elm),
   _L = _N.List.make(_elm),
   _A = _N.Array.make(_elm),
   _E = _N.Error.make(_elm),
   $moduleName = "Touch.Signal.Derived";
   var Basics = Elm.Basics.make(_elm);
   var Color = Elm.Color.make(_elm);
   var Graphics = Graphics || {};
   Graphics.Collage = Elm.Graphics.Collage.make(_elm);
   var Graphics = Graphics || {};
   Graphics.Element = Elm.Graphics.Element.make(_elm);
   var List = Elm.List.make(_elm);
   var Maybe = Elm.Maybe.make(_elm);
   var Native = Native || {};
   Native.Json = Elm.Native.Json.make(_elm);
   var Native = Native || {};
   Native.Ports = Elm.Native.Ports.make(_elm);
   var Signal = Elm.Signal.make(_elm);
   var String = Elm.String.make(_elm);
   var Text = Elm.Text.make(_elm);
   var Time = Elm.Time.make(_elm);
   var _op = {};
   var onceWhen = F3(function (dflt,
   pred,
   s) {
      return function () {
         var zero = {ctor: "_Tuple2"
                    ,_0: {ctor: "_Tuple2"
                         ,_0: true
                         ,_1: true}
                    ,_1: Maybe.Nothing};
         var switched = function (_v0) {
            return function () {
               switch (_v0.ctor)
               {case "_Tuple2":
                  switch (_v0._0.ctor)
                    {case "_Tuple2":
                       return _v0._0._0 && Basics.not(_v0._0._1);}
                    break;}
               _E.Case($moduleName,
               "on line 58, column 32 to 44");
            }();
         };
         var f = F2(function (_v6,_v7) {
            return function () {
               switch (_v7.ctor)
               {case "_Tuple2":
                  switch (_v7._0.ctor)
                    {case "_Tuple2":
                       return function () {
                            switch (_v6.ctor)
                            {case "_Tuple2":
                               return {ctor: "_Tuple2"
                                      ,_0: {ctor: "_Tuple2"
                                           ,_0: _v6._0
                                           ,_1: _v7._0._0}
                                      ,_1: Maybe.Just(_v6._1)};}
                            _E.Case($moduleName,
                            "on line 57, column 36 to 55");
                         }();}
                    break;}
               _E.Case($moduleName,
               "on line 57, column 36 to 55");
            }();
         });
         var sig = A2(Signal._op["~"],
         A2(Signal._op["<~"],
         F2(function (v0,v1) {
            return {ctor: "_Tuple2"
                   ,_0: v0
                   ,_1: v1};
         }),
         pred),
         s);
         return A2(Signal._op["<~"],
         function ($) {
            return A2(Maybe.maybe,
            dflt,
            Basics.id)(Basics.snd($));
         },
         A3(Signal.keepIf,
         switched,
         zero,
         A3(Signal.foldp,f,zero,sig)));
      }();
   });
   var dumpAfter = function (n) {
      return A2(Signal.foldp,
      F2(function (x,acc) {
         return _U.cmp(List.length(acc),
         n) < 0 ? {ctor: "::"
                  ,_0: x
                  ,_1: acc} : _L.fromArray([x]);
      }),
      _L.fromArray([]));
   };
   var catchN = F2(function (n,s) {
      return A2(Signal.keepIf,
      function (xs) {
         return _U.eq(List.length(xs),
         n);
      },
      _L.fromArray([]))(A2(dumpAfter,
      n,
      s));
   });
   var catchPair = F2(function (dflt,
   s) {
      return function () {
         var toPair = function (pair) {
            return function () {
               switch (pair.ctor)
               {case "::":
                  switch (pair._1.ctor)
                    {case "::":
                       switch (pair._1._1.ctor)
                         {case "[]":
                            return {ctor: "_Tuple2"
                                   ,_0: pair._1._0
                                   ,_1: pair._0};}
                         break;}
                    break;}
               return dflt;
            }();
         };
         return A2(Signal._op["<~"],
         toPair,
         A2(catchN,2,s));
      }();
   });
   var collectN = function (n) {
      return A2(Signal.foldp,
      F2(function (x,acc) {
         return List.take(n)({ctor: "::"
                             ,_0: x
                             ,_1: acc});
      }),
      _L.fromArray([]));
   };
   var collect = A2(Signal.foldp,
   F2(function (x,y) {
      return {ctor: "::"
             ,_0: x
             ,_1: y};
   }),
   _L.fromArray([]));
   _elm.Touch.Signal.Derived.values = {_op: _op
                                      ,collect: collect
                                      ,collectN: collectN
                                      ,dumpAfter: dumpAfter
                                      ,catchPair: catchPair
                                      ,catchN: catchN
                                      ,onceWhen: onceWhen};
   return _elm.Touch.Signal.Derived.values;
};Elm.Touch = Elm.Touch || {};
Elm.Touch.Swipe = Elm.Touch.Swipe || {};
Elm.Touch.Swipe.make = function (_elm) {
   "use strict";
   _elm.Touch = _elm.Touch || {};
   _elm.Touch.Swipe = _elm.Touch.Swipe || {};
   if (_elm.Touch.Swipe.values)
   return _elm.Touch.Swipe.values;
   var _N = Elm.Native,
   _U = _N.Utils.make(_elm),
   _L = _N.List.make(_elm),
   _A = _N.Array.make(_elm),
   _E = _N.Error.make(_elm),
   $moduleName = "Touch.Swipe";
   var Basics = Elm.Basics.make(_elm);
   var Color = Elm.Color.make(_elm);
   var Graphics = Graphics || {};
   Graphics.Collage = Elm.Graphics.Collage.make(_elm);
   var Graphics = Graphics || {};
   Graphics.Element = Elm.Graphics.Element.make(_elm);
   var List = Elm.List.make(_elm);
   var Maybe = Elm.Maybe.make(_elm);
   var Native = Native || {};
   Native.Json = Elm.Native.Json.make(_elm);
   var Native = Native || {};
   Native.Ports = Elm.Native.Ports.make(_elm);
   var Signal = Elm.Signal.make(_elm);
   var String = Elm.String.make(_elm);
   var Text = Elm.Text.make(_elm);
   var Time = Elm.Time.make(_elm);
   var Touch = Elm.Touch.make(_elm);
   var Touch = Touch || {};
   Touch.Types = Elm.Touch.Types.make(_elm);
   var Touch = Touch || {};
   Touch.Util = Elm.Touch.Util.make(_elm);
   var _op = {};
   var threeFinger = Touch.Types.Swipe(Touch.Types.ThreeFinger);
   var twoFinger = Touch.Types.Swipe(Touch.Types.TwoFinger);
   var oneFinger = Touch.Types.Swipe(Touch.Types.OneFinger);
   var fromTouches = function (ts) {
      return function () {
         var dflt = _L.fromArray([{_: {}
                                  ,id: 0
                                  ,t0: 0
                                  ,x: 0
                                  ,x0: 0
                                  ,y: 0
                                  ,y0: 0}]);
         var a = function (t) {
            return {ctor: "_Tuple2"
                   ,_0: {ctor: "_Tuple2"
                        ,_0: t.x0
                        ,_1: t.y0}
                   ,_1: {ctor: "_Tuple2"
                        ,_0: t.x
                        ,_1: t.y}};
         };
         return function () {
            var _v0 = List.length(ts);
            switch (_v0)
            {case 0:
               return oneFinger(A2(List.map,
                 a,
                 dflt));
               case 1:
               return oneFinger(A2(List.map,
                 a,
                 ts));
               case 2:
               return twoFinger(A2(List.map,
                 a,
                 ts));}
            return threeFinger(List.take(3)(A2(List.map,
            a,
            ts)));
         }();
      }();
   };
   _elm.Touch.Swipe.values = {_op: _op
                             ,oneFinger: oneFinger
                             ,twoFinger: twoFinger
                             ,threeFinger: threeFinger
                             ,fromTouches: fromTouches};
   return _elm.Touch.Swipe.values;
};Elm.Touch = Elm.Touch || {};
Elm.Touch.Tap = Elm.Touch.Tap || {};
Elm.Touch.Tap.make = function (_elm) {
   "use strict";
   _elm.Touch = _elm.Touch || {};
   _elm.Touch.Tap = _elm.Touch.Tap || {};
   if (_elm.Touch.Tap.values)
   return _elm.Touch.Tap.values;
   var _N = Elm.Native,
   _U = _N.Utils.make(_elm),
   _L = _N.List.make(_elm),
   _A = _N.Array.make(_elm),
   _E = _N.Error.make(_elm),
   $moduleName = "Touch.Tap";
   var Basics = Elm.Basics.make(_elm);
   var Color = Elm.Color.make(_elm);
   var Graphics = Graphics || {};
   Graphics.Collage = Elm.Graphics.Collage.make(_elm);
   var Graphics = Graphics || {};
   Graphics.Element = Elm.Graphics.Element.make(_elm);
   var List = Elm.List.make(_elm);
   var Maybe = Elm.Maybe.make(_elm);
   var Native = Native || {};
   Native.Json = Elm.Native.Json.make(_elm);
   var Native = Native || {};
   Native.Ports = Elm.Native.Ports.make(_elm);
   var Signal = Elm.Signal.make(_elm);
   var String = Elm.String.make(_elm);
   var Text = Elm.Text.make(_elm);
   var Time = Elm.Time.make(_elm);
   var Touch = Touch || {};
   Touch.Types = Elm.Touch.Types.make(_elm);
   var _op = {};
   var threeFinger = Touch.Types.Tap(Touch.Types.ThreeFinger);
   var twoFinger = Touch.Types.Tap(Touch.Types.TwoFinger);
   var oneFinger = Touch.Types.Tap(Touch.Types.OneFinger);
   var fromPrimTap = function (_v0) {
      return function () {
         return oneFinger(_L.fromArray([{ctor: "_Tuple2"
                                        ,_0: _v0.x
                                        ,_1: _v0.y}]));
      }();
   };
   _elm.Touch.Tap.values = {_op: _op
                           ,oneFinger: oneFinger
                           ,twoFinger: twoFinger
                           ,threeFinger: threeFinger
                           ,fromPrimTap: fromPrimTap};
   return _elm.Touch.Tap.values;
};Elm.Touch = Elm.Touch || {};
Elm.Touch.Util = Elm.Touch.Util || {};
Elm.Touch.Util.make = function (_elm) {
   "use strict";
   _elm.Touch = _elm.Touch || {};
   _elm.Touch.Util = _elm.Touch.Util || {};
   if (_elm.Touch.Util.values)
   return _elm.Touch.Util.values;
   var _N = Elm.Native,
   _U = _N.Utils.make(_elm),
   _L = _N.List.make(_elm),
   _A = _N.Array.make(_elm),
   _E = _N.Error.make(_elm),
   $moduleName = "Touch.Util";
   var Basics = Elm.Basics.make(_elm);
   var Color = Elm.Color.make(_elm);
   var Graphics = Graphics || {};
   Graphics.Collage = Elm.Graphics.Collage.make(_elm);
   var Graphics = Graphics || {};
   Graphics.Element = Elm.Graphics.Element.make(_elm);
   var List = Elm.List.make(_elm);
   var Maybe = Elm.Maybe.make(_elm);
   var Native = Native || {};
   Native.Json = Elm.Native.Json.make(_elm);
   var Native = Native || {};
   Native.Ports = Elm.Native.Ports.make(_elm);
   var Signal = Elm.Signal.make(_elm);
   var String = Elm.String.make(_elm);
   var Text = Elm.Text.make(_elm);
   var Time = Elm.Time.make(_elm);
   var Touch = Elm.Touch.make(_elm);
   var Touch = Touch || {};
   Touch.Types = Elm.Touch.Types.make(_elm);
   var _op = {};
   var tupFromRec = function (_v0) {
      return function () {
         return {ctor: "_Tuple2"
                ,_0: _v0.x
                ,_1: _v0.y};
      }();
   };
   var isTap = function (_v2) {
      return function () {
         return _U.eq(_v2.x0,
         _v2.x) && _U.eq(_v2.y0,_v2.y);
      }();
   };
   var dot = F2(function (_v4,
   _v5) {
      return function () {
         switch (_v5.ctor)
         {case "_Tuple2":
            return function () {
                 switch (_v4.ctor)
                 {case "_Tuple2":
                    return _v4._0 * _v5._0 + _v4._1 + _v5._1;}
                 _E.Case($moduleName,
                 "on line 51, column 23 to 40");
              }();}
         _E.Case($moduleName,
         "on line 51, column 23 to 40");
      }();
   });
   var lineSegToVector2 = function (_v12) {
      return function () {
         switch (_v12.ctor)
         {case "_Tuple2":
            switch (_v12._0.ctor)
              {case "_Tuple2":
                 switch (_v12._1.ctor)
                   {case "_Tuple2":
                      return {ctor: "_Tuple2"
                             ,_0: Basics.toFloat(_v12._0._1 - _v12._1._1)
                             ,_1: Basics.toFloat(_v12._1._0 - _v12._0._0)};}
                   break;}
              break;}
         _E.Case($moduleName,
         "on line 46, column 39 to 75");
      }();
   };
   var distance = F2(function (_v20,
   _v21) {
      return function () {
         switch (_v21.ctor)
         {case "_Tuple2":
            return function () {
                 switch (_v20.ctor)
                 {case "_Tuple2":
                    return function () {
                         var b = _v21._1 - _v20._1;
                         var a = _v21._0 - _v20._0;
                         return Basics.sqrt(Math.pow(a,
                         2) + Math.pow(b,2));
                      }();}
                 _E.Case($moduleName,
                 "between lines 39 and 41");
              }();}
         _E.Case($moduleName,
         "between lines 39 and 41");
      }();
   });
   var angle = F2(function (_v28,
   _v29) {
      return function () {
         switch (_v29.ctor)
         {case "_Tuple2":
            return function () {
                 switch (_v28.ctor)
                 {case "_Tuple2":
                    return A2(Basics.atan2,
                      Basics.toFloat(_v28._1 - _v29._1),
                      Basics.toFloat(_v29._0 - _v28._0));}
                 _E.Case($moduleName,
                 "on line 29, column 25 to 68");
              }();}
         _E.Case($moduleName,
         "on line 29, column 25 to 68");
      }();
   });
   var lineSegAngle = Basics.uncurry(angle);
   _elm.Touch.Util.values = {_op: _op
                            ,angle: angle
                            ,lineSegAngle: lineSegAngle
                            ,distance: distance
                            ,lineSegToVector2: lineSegToVector2
                            ,dot: dot
                            ,isTap: isTap
                            ,tupFromRec: tupFromRec};
   return _elm.Touch.Util.values;
};Elm.Touch = Elm.Touch || {};
Elm.Touch.Types = Elm.Touch.Types || {};
Elm.Touch.Types.make = function (_elm) {
   "use strict";
   _elm.Touch = _elm.Touch || {};
   _elm.Touch.Types = _elm.Touch.Types || {};
   if (_elm.Touch.Types.values)
   return _elm.Touch.Types.values;
   var _N = Elm.Native,
   _U = _N.Utils.make(_elm),
   _L = _N.List.make(_elm),
   _A = _N.Array.make(_elm),
   _E = _N.Error.make(_elm),
   $moduleName = "Touch.Types";
   var Basics = Elm.Basics.make(_elm);
   var Color = Elm.Color.make(_elm);
   var Graphics = Graphics || {};
   Graphics.Collage = Elm.Graphics.Collage.make(_elm);
   var Graphics = Graphics || {};
   Graphics.Element = Elm.Graphics.Element.make(_elm);
   var List = Elm.List.make(_elm);
   var Maybe = Elm.Maybe.make(_elm);
   var Native = Native || {};
   Native.Json = Elm.Native.Json.make(_elm);
   var Native = Native || {};
   Native.Ports = Elm.Native.Ports.make(_elm);
   var Signal = Elm.Signal.make(_elm);
   var String = Elm.String.make(_elm);
   var Text = Elm.Text.make(_elm);
   var Time = Elm.Time.make(_elm);
   var _op = {};
   var ThreeFinger = {ctor: "ThreeFinger"};
   var TwoFinger = {ctor: "TwoFinger"};
   var OneFinger = {ctor: "OneFinger"};
   var Tap = F2(function (a,b) {
      return {ctor: "Tap"
             ,_0: a
             ,_1: b};
   });
   var Swipe = F2(function (a,b) {
      return {ctor: "Swipe"
             ,_0: a
             ,_1: b};
   });
   _elm.Touch.Types.values = {_op: _op
                             ,Swipe: Swipe
                             ,Tap: Tap
                             ,OneFinger: OneFinger
                             ,TwoFinger: TwoFinger
                             ,ThreeFinger: ThreeFinger};
   return _elm.Touch.Types.values;
};