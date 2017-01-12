%-----------------------------------------------------------------------------------------------------------------------------------------
%Initializations
%-----------------------------------------------------------------------------------------------------------------------------------------
:- nb_setval(gameDEV, false),
   nb_setval(gameName, false),
   nb_setval(dimension, false),
   nb_setval(board, false),
   nb_setval(clear, false),
   nb_setval(reset, false),
   nb_setval(capture, false),
   nb_setval(logic, false),
   nb_setval(boardconfig, false),
   nb_setval(timer, false),
   nb_setval(queen, 0),
   nb_setval(king, 0),
   nb_setval(rook, 0),
   nb_setval(knight, 0),
   nb_setval(bishop, 0),
   nb_setval(pawn, 0),
   nb_setval(pieceCount, 0).   

%-----------------------------------------------------------------------------------------------------------------------------------------
%Generate game files and set initial game variables
%-----------------------------------------------------------------------------------------------------------------------------------------

startGameDEV:- nb_getval(gameDEV, Valid), \+Valid,
			   nb_setval(gameDEV, true),
			   write('Game Development Begins.'),
			   open('main.lua', write, Stream0), close(Stream0),
			   open('conf.lua', write, Stream1),
			   write(Stream1, 'function love.conf(t)\nt.version = "0.10.1"\nmath.randomseed(os.time())\n'), close(Stream1),
			   open('update.lua', write, Stream2),
			   write(Stream2, '\nfunction love.update(dt)\ntimer = timer + love.timer.getDelta()'), close(Stream2),
			   open('load.lua', write, Stream3),
			   write(Stream3, '\nfunction love.load()\nt1 = love.graphics.newImage("assets/tile1.png")\nt2 = love.graphics.newImage("assets/tile2.png")\nt3 = love.graphics.newImage("assets/highlight.png")		
			   \np = love.graphics.newImage("assets/pawn.png")\nn = love.graphics.newImage("assets/knight.png")\nb = love.graphics.newImage("assets/bishop.png")\n\nr = love.graphics.newImage("assets/rook.png")\nq = love.graphics.newImage("assets/queen.png")\nk = love.graphics.newImage("assets/king.png")
			   \npressedTile = {i = -1, j = -1, ctr = 0, piece = 0}\n\nans = {t = "invalid"}\ncapture = true
			   \ntimer = love.timer.getDelta()\n'),
			   close(Stream3).

%-----------------------------------------------------------------------------------------------------------------------------------------
%Specify name of the game
%-----------------------------------------------------------------------------------------------------------------------------------------

nameOfTheGame(X):- nb_getval(gameDEV, Valid), Valid,
				   nb_getval(gameName, V1), \+V1,
				   open('conf.lua', append, Stream),
				   write(Stream, 't.title = "'), write(Stream, X), write(Stream,'"\n'),
				   close(Stream),
				   nb_setval(gameName, true), !.

%-----------------------------------------------------------------------------------------------------------------------------------------
%Set board dimensions and generate standard chess-board orientation 
%-----------------------------------------------------------------------------------------------------------------------------------------

gridSize(X):- nb_getval(gameDEV, Valid), Valid,
			  nb_getval(dimension, V1), \+V1,
			  open('conf.lua', append, Stream),
			  N is X * 90,
			  N1 is X * X,
			  nb_setval(size, X),
			  write(Stream, 't.window.height = '), write(Stream, N+20), write(Stream, '\n'),
			  write(Stream, 't.window.width = '), write(Stream, N), write(Stream, '\n'),
			  close(Stream),
			  generateTiles(N1),
			  board(N1),
			  nb_setval(dimension, true), !.

tiles(1):- open('load.lua', append, Input),
		   write(Input, 't1}\n'), nb_getval(size, S),
		   write(Input, '\nsize = '), write(Input, S),
		   close(Input).
				     
tiles(X):- X > 1,
		   open('load.lua', append, Str),
		   T is mod(X, 2),
		   T =:= 0, write(Str, 't2,'), T1 is X - 1, close(Str), tiles(T1);
		   open('load.lua', append, Str),
		   write(Str, 't1,'),
		   T1 is X - 1,
		   close(Str),
		   tiles(T1).

generateTiles(X):- open('load.lua', append, Input),
				   write(Input, '\ntiles = {'),
				   close(Input),
				   tiles(X). 

board(Z):- open('Temp.txt', write, Stream),
		   write(Stream, '\nboard = {'),
		   close(Stream),
		   Slots is round(Z*1.5),
		   nb_setval(slots, Slots).

%-----------------------------------------------------------------------------------------------------------------------------------------
%Assign chess pieces to board
%-----------------------------------------------------------------------------------------------------------------------------------------

assignBoard(_, 0). 

assignBoard(Piece, Number):- Number > 0,
							 nb_getval(gameName, V1), V1,
							 nb_getval(dimension, V2), V2,
							 nb_getval(boardconfig, V3), \+V3,
							 open('Temp.txt', append, Stream),
							 write(Stream, Piece), write(Stream, ','),
							 close(Stream),
							 nb_getval(pieceCount, C),
							 C1 is C + 1,
							 N1 is Number - 1,
							 nb_setval(pieceCount, C1),
							 assignBoard(Piece, N1), !.

addQueen:- nb_getval(queen, Number),
		   Number =:= 0,
		   assignBoard(q, 1),
		   nb_setval(queen, 1).

addKing:- nb_getval(king, Number),
		  Number =:= 0,
		  assignBoard(k, 1),
		  nb_setval(king, 1).

addRook(N1):- nb_getval(rook, Number),
		  	  N2 is Number + N1,
		  	  N2 < 3,
		  	  assignBoard(r, N1),
		   	  nb_setval(rook, N2).

addBishop(N1):- nb_getval(bishop, Number),
		  	  	N2 is Number + N1,
		  	  	N2 < 3,
		  	  	assignBoard(b, N1),
		   	  	nb_setval(bishop, N2).

addKnight(N1):- nb_getval(knight, Number),
		  	  	N2 is Number + N1,
		  	  	N2 < 3,
		  	  	assignBoard(n, N1),
		   	  	nb_setval(knight, N2).

addPawn(N1):- nb_getval(pawn, Number),
		  	  N2 is Number + N1,
		  	  N2 < 9,
		  	  assignBoard(p, N1),
		   	  nb_setval(pawn, N2).

%-----------------------------------------------------------------------------------------------------------------------------------------
%Specify whether capture is mandatory
%-----------------------------------------------------------------------------------------------------------------------------------------

mustCapture:- nb_getval(gameDEV, A), A,
			  nb_getval(capture, Valid), \+Valid,
			  open('load.lua', append, Stream),
			  write(Stream, '\ncapture = false'),
			  close(Stream),
			  nb_setval(capture, true).

%-----------------------------------------------------------------------------------------------------------------------------------------
%Assign a keyboard key to shuffle the board configuration or to clear current chess-piece selection
%-----------------------------------------------------------------------------------------------------------------------------------------

keyForReset(X):- checkBoardConfig,
				 nb_getval(reset, Valid), \+Valid,
				 open('update.lua', append, Stream),
				 write(Stream, '\nif love.keyboard.isDown(\''), write(Stream, X), write(Stream, '\') then\n'),
				 write(Stream, 'pressedTile.i = -1\npressedTile.j = -1\npressedTile.ctr = 0\npressedTile.piece = 0\n'),
				 close(Stream),
				 copyContent('Temp.txt', 'update.lua'),
				 open('update.lua', append, Input),
				 write(Input, '\nshuffle(board)\nend'),
				 close(Input),
				 nb_setval(reset, true), !.

keyForClear(X):- nb_getval(gameDEV, V1), V1,
				 nb_getval(clear, V2), \+V2,
				 open('update.lua', append, Stream),
				 write(Stream, '\nif love.keyboard.isDown(\''), write(Stream, X), write(Stream, '\') then\n'),
				 write(Stream, 'pressedTile.i = -1\npressedTile.j = -1\npressedTile.ctr = 0\npressedTile.piece = 0\nend'),
				 close(Stream),
				 nb_setval(clear, true).

%-----------------------------------------------------------------------------------------------------------------------------------------
%Add a clock to the game
%-----------------------------------------------------------------------------------------------------------------------------------------

addTimer:- nb_getval(gameDEV, V1), V1,
		   nb_getval(logic, V2), \+V2,
		   nb_setval(timer, true).
		   %open('load.lua', append, Stream), write(Stream, '\nhasTimer = true'), close(Stream).

%-----------------------------------------------------------------------------------------------------------------------------------------
%Miscellanious Functions to implement standard chess logic
%-----------------------------------------------------------------------------------------------------------------------------------------

mousepressed:- open('main.lua', append, Stream),
			   write(Stream, '\nfunction love.mousepressed(x, y, button)\nif button == 1 then\nfindTile(x, y)\nend\nend'),
			   close(Stream).

shuffle:- open('main.lua', append, Stream),
		  write(Stream, '\n\nfunction shuffle(a)\nfor i = 1, #a do\nlocal b = math.random(1,#a)\na[b], a[i] = a[i], a[b]
				\nend\nreturn a\nend'),
		  close(Stream).

draw:- nb_getval(size, X),
	   open('main.lua', append, Stream),
	   write(Stream, '\n\nfunction love.draw()\nlocal x = 1\nfor i = 1,'), write(Stream, X), write(Stream, ' do'),
	   write(Stream,'\nfor j = 1,'), write(Stream, X), write(Stream, ' do'),
	   write(Stream, '\nif i == pressedTile.i and j == pressedTile.j and board[pressedTile.ctr] ~= 0 then\nlove.graphics.draw(t3, j*90-90, i*90-90)
			 \nelse\nlove.graphics.draw(tiles[i+j-1], j*90-90, i*90-90)\nend\nif board[x] ~= 0 then\nlove.graphics.draw(board[x], j*90-90, i*90-90)
			 \nend\nx = x + 1\nend\nend\n'),
	   %write(Stream, 'love.graphics.print("Score: ".. score .." ", love.graphics.getWidth()/2, (love.graphics.getHeight()-15))\n'),
	   close(Stream).

assignZeros(1):- open('Temp.txt', append, Stream),
				 write(Stream, '0}'),
				 close(Stream).

assignZeros(X):- X > 1,
				 open('Temp.txt', append, Stream),
				 write(Stream, '0,'),
				 close(Stream),
				 X1 is X - 1,
				 assignZeros(X1).

checkBoardConfig:- nb_getval(boardconfig, Valid), \+Valid,
				   nb_getval(slots, N1),
				   nb_getval(pieceCount, N2),
				   N is N1 - N2,
				   N > 0,
				   assignZeros(N),
				   copyContent('Temp.txt', 'load.lua'),
				   open('load.lua', append, Stream), write(Stream, '\nshuffle(board)'), close(Stream),
				   nb_setval(boardconfig, true); write('').

checkForTimer:- nb_getval(timer, Valid), Valid,
				open('main.lua', append, Stream),
				write(Stream, 'love.graphics.print("Time: ".. math.floor(timer) .." seconds", 0, love.graphics.getHeight()-15)\nend'), close(Stream);
				open('main.lua', append, Stream), write(Stream, '\nend'), close(Stream). 

addMiscFunctions:- mousepressed, shuffle, draw, checkForTimer.

%-----------------------------------------------------------------------------------------------------------------------------------------
%Apply standard chess logic to the game
%-----------------------------------------------------------------------------------------------------------------------------------------

applyChessLogic:- checkBoardConfig,
				  nb_getval(logic, V2), \+V2,
			      copyContent('ChessLogic.txt', 'main.lua'),
				  addMiscFunctions,
				  nb_setval(logic, true), !.

%-----------------------------------------------------------------------------------------------------------------------------------------
%End game developement. Close all files. Run the game.
%-----------------------------------------------------------------------------------------------------------------------------------------

endFile(File):- open(File, append, Input),
				write(Input, '\nend'),
				close(Input).

endGameDEV:- nb_getval(gameDEV, Valid), Valid,
			 endFile('load.lua'), endFile('conf.lua'), endFile('update.lua'),
			 copyContent('load.lua', 'main.lua'), copyContent('update.lua', 'main.lua'),
			 shell("rm Temp.txt"), shell("rm load.lua"), shell("rm update.lua"),
			 shell("zip -9 -r Game.love conf.lua main.lua assets"),
			 shell("love Game.love"),
			 shell("halt").

%-----------------------------------------------------------------------------------------------------------------------------------------
%Copy the content of one file to another
%-----------------------------------------------------------------------------------------------------------------------------------------

copyContent(File1, File2):- open(File1, read, Stream1),
							open(File2, append, Stream2),
							copy_stream_data(Stream1, Stream2),
							close(Stream1), close(Stream2).

%-----------------------------------------------------------------------------------------------------------------------------------------
%END
%-----------------------------------------------------------------------------------------------------------------------------------------
