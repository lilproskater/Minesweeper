unit MineSweeper_game;

interface
Uses GraphABC, MineSweeper_Engine;

const CellsInRow = 16;
const bombsInGrid = Round(Sqr(CellsInRow) / 6.4);
const CellSize = Round(ScreenHeight / CellsInRow / 1.2);

var victory, lose, exit_playing, exit_window_show: boolean;

procedure Init_Party();
procedure GameMouseDown(MouseX, MouseY, mouseButton: integer);
procedure Draw_Grid();
procedure CheckGameStatus();
procedure GameKeyDown(key: integer);
procedure ExitWindow_Interface();
procedure ExitWindow_KD(key: integer);
procedure ExitWindow_MD(MouseX, MouseY, mouseButton: integer);


implementation

var grid: array [0..CellsInRow - 1, 0..CellsInRow - 1] of Cell; 

procedure UpdateWindow();
begin
  try 
    Redraw();
  except
  
  end;
end;

procedure OpenCells(y_grid, x_grid: integer);
begin
  if grid[y_grid, x_grid].contains_mine then exit;
  if grid[y_grid, x_grid].revealed then exit;
  if grid[y_grid, x_grid].number <> 0 then exit;
  if not grid[y_grid, x_grid].flag_is_put then grid[y_grid, x_grid].Click(1);
  if y_grid > 0 then OpenCells(y_grid - 1, x_grid);
  if y_grid < CellsInRow - 1 then OpenCells(y_grid + 1, x_grid);
  if x_grid > 0 then OpenCells(y_grid, x_grid - 1);
  if x_grid < CellsInRow - 1 then OpenCells(y_grid, x_grid + 1);
  
  //Reveal nearby cells with nubmers
  if y_grid > 0 then if grid[y_grid - 1, x_grid].number <> 0 then grid[y_grid - 1, x_grid].Click(1);
  if y_grid < CellsInRow - 1 then if grid[y_grid + 1, x_grid].number <> 0 then grid[y_grid + 1, x_grid].Click(1);
  if x_grid > 0 then if grid[y_grid, x_grid - 1].number <> 0 then grid[y_grid, x_grid - 1].Click(1);
  if x_grid < CellsInRow - 1 then if grid[y_grid, x_grid + 1].number <> 0 then grid[y_grid, x_grid + 1].Click(1);
  if (y_grid > 0) and (x_grid > 0) then if grid[y_grid - 1, x_grid - 1].number <> 0 then grid[y_grid - 1, x_grid - 1].Click(1);
  if (y_grid > 0) and (x_grid < CellsInRow - 1) then if grid[y_grid - 1, x_grid + 1].number <> 0 then grid[y_grid - 1, x_grid + 1].Click(1);
  if (y_grid < CellsInRow - 1) and (x_grid > 0) then if grid[y_grid + 1, x_grid - 1].number <> 0 then grid[y_grid + 1, x_grid - 1].Click(1);
  if (y_grid < CellsInRow - 1) and (x_grid < CellsInRow - 1) then if grid[y_grid + 1, x_grid + 1].number <> 0 then grid[y_grid + 1, x_grid + 1].Click(1);
end;

procedure Init_Party();
begin
  //Firstly setting all cells empty
  //Setting x and y positions for each cell
  lose := false;
  victory := false;
  first_click := true;
  mine_is_pressed := false;
  exit_playing := false;
  var pos_x := 0;
  var pos_y := 0;
  for var y := 0 to CellsInRow - 1 do
    for var x := 0 to CellsInRow - 1 do
    begin
      grid[y, x] := new Cell(pos_x, pos_y, pos_x + CellSize, pos_y + CellSize, false);
      if pos_x + CellSize >= WindowWidth then
      begin
        pos_x := 0;
        pos_y += CellSize;
      end
      else pos_x += CellSize;  
    end;
  
  //Setting Up Bombs
  var bombs_counter := bombsInGrid;
  while bombs_counter > 0 do
  begin
    var x := Random(0, CellsInRow - 1);
    var y := Random(0, CellsInRow - 1);
    if not grid[y, x].contains_mine then grid[y, x].contains_mine := true
      else continue;
    bombs_counter -= 1;    
  end;
  
  //Setting Up Numbers
  for var y := 0 to CellsInRow - 1 do
    for var x := 0 to CellsInRow - 1 do
    begin
      var number := 0;
      if x > 0 then if grid[y, x - 1].contains_mine then number += 1;
      if y > 0 then if grid[y - 1, x].contains_mine then number += 1;
      if y < CellsInRow - 1 then if grid[y + 1, x].contains_mine then number += 1;
      if x < CellsInRow - 1 then if grid[y, x + 1].contains_mine then number += 1;
      if (x > 0) and (y > 0) then if grid[y - 1, x - 1].contains_mine then number += 1;
      if (y > 0) and (x < CellsInRow - 1) then if grid[y - 1, x + 1].contains_mine then number += 1;
      if (y < CellsInRow - 1) and (x > 0) then if grid[y + 1, x - 1].contains_mine then number += 1;
      if (y < CellsInRow - 1) and (x < CellsInRow - 1) then if grid[y + 1, x + 1].contains_mine then number += 1;
      grid[y, x].number := number;
    end;
end;

procedure GameMouseDown(MouseX, MouseY, mouseButton: integer);
begin
  if not (lose) and not (victory) then
  begin
    var y := Trunc(MouseY / (WindowHeight / CellsInRow));
    var x := Trunc(MouseX / (WindowWidth / CellsInRow));
    if mouseButton = 1 then 
    begin
      if (grid[y, x].number <> 0) or (grid[y, x].contains_mine) then grid[y, x].Click(1)
        else OpenCells(y, x);
      if first_click then 
      begin
        if mine_is_pressed then
        begin
          mine_is_pressed := false;
          while grid[y, x].contains_mine do
            Init_Party();
          if grid[y, x].number <> 0 then grid[y, x].Click(1)
            else OpenCells(y, x); 
        end;
        first_click := false;
      end;
    end
      else grid[y, x].Click(mouseButton);
  end
  else
  begin
    if (mouseButton = 1) and (MouseX > Round(WindowWidth / 36)) and (MouseY > WindowHeight - Round(WindowHeight / 6)) and (MouseX < Round(WindowWidth / 6)) and (MouseY < WindowHeight - Round(WindowHeight / 36)) then exit_playing := true;
    if (mouseButton = 1) and (MouseX > Round(WindowWidth /4.235)) and (MouseY > WindowHeight - Round(WindowHeight / 6)) and (MouseX < Round(WindowWidth / 2.666)) and (MouseY < WindowHeight - Round(WindowHeight / 36)) then Init_Party();
  end; 
end;

procedure Draw_Grid();
begin
  SetPenWidth(1);
  SetPenColor(rgb(0, 0, 0));
  for var y := 0 to CellsInRow - 1 do
    for var x := 0 to CellsInRow - 1 do
      grid[y, x].Draw();
  if lose then
  begin
    SetFontColor(clRed);
    SetFontSize(Round(WindowHeight / 7.2));
    DrawTextCentered(0, 0, WindowWidth, WindowHeight, 'You Lose!');
    SetFontSize(Round(WindowHeight / 14.4));
    SetPenWidth(Round(WindowHeight / 102.857));
    SetPenColor(rgb(255, 255, 255));
    SetBrushColor(rgb(185, 185, 185));
    Rectangle(Round(WindowWidth / 36), WindowHeight - Round(WindowHeight / 6), Round(WindowWidth / 6), WindowHeight - Round(WindowHeight / 36));
    Rectangle(Round(WindowWidth /4.235), WindowHeight - Round(WindowHeight / 6), Round(WindowWidth / 2.666), WindowHeight - Round(WindowHeight / 36));
    SetFontColor(rgb(255, 255, 255));
    DrawTextCentered(Round(WindowWidth / 36), WindowHeight - Round(WindowHeight / 6), Round(WindowWidth / 6), WindowHeight - Round(WindowHeight / 36), '←');
    DrawTextCentered(Round(WindowWidth /4.235), WindowHeight - Round(WindowHeight / 6), Round(WindowWidth / 2.666), WindowHeight - Round(WindowHeight / 36), '►');
  end;
  if victory then
  begin
    SetFontColor(clLime);
    SetFontSize(Round(WindowHeight / 7.2));
    DrawTextCentered(0, 0, WindowWidth, WindowHeight, 'You Won!');
    SetFontSize(Round(WindowHeight / 14.4));
    SetPenWidth(Round(WindowHeight / 102.857));
    SetPenColor(rgb(255, 255, 255));
    SetBrushColor(rgb(185, 185, 185));
    Rectangle(Round(WindowWidth / 36), WindowHeight - Round(WindowHeight / 6), Round(WindowWidth / 6), WindowHeight - Round(WindowHeight / 36));
    Rectangle(Round(WindowWidth /4.235), WindowHeight - Round(WindowHeight / 6), Round(WindowWidth / 2.666), WindowHeight - Round(WindowHeight / 36));
    SetFontColor(rgb(255, 255, 255));
    DrawTextCentered(Round(WindowWidth / 36), WindowHeight - Round(WindowHeight / 6), Round(WindowWidth / 6), WindowHeight - Round(WindowHeight / 36), '←');
    DrawTextCentered(Round(WindowWidth /4.235), WindowHeight - Round(WindowHeight / 6), Round(WindowWidth / 2.666), WindowHeight - Round(WindowHeight / 36), '►');
 end;
  UpdateWindow();
end;

procedure CheckGameStatus();
begin
  if mine_is_pressed then
    lose := true
  else
  begin
    var count_unrevealed := 0;
    for var y := 0 to CellsInRow - 1 do
      for var x := 0 to CellsInRow - 1 do
       if not grid[y, x].revealed then count_unrevealed += 1;
    if count_unrevealed = bombsInGrid then victory := true;
  end;
end;

procedure GameKeyDown(key: integer);
begin
  if (key = VK_Escape) and not (lose) and not (victory) then exit_window_show := true
    else exit_window_show := false;
  if (key = VK_Escape) and ((lose) or (victory)) then
    exit_playing := true;
  if (key = VK_Enter) and ((lose) or (victory)) then
    Init_Party();
end;

procedure ExitWindow_Interface();
begin
  SetPenColor(rgb(255, 255, 255));
  SetBrushColor(rgb(185, 185, 185));
  SetFontColor(rgb(255, 255, 255));
  SetPenWidth(Round(WindowHeight / 102.835));
  Rectangle(Round(WindowWidth / 14.4), Round(WindowHeight / 14.4), WindowWidth - Round(WindowWidth / 14.4), WindowHeight - Round(WindowHeight / 14.4));
  SetFontSize(Round(WindowHeight / 20.571));
  DrawTextCentered(Round(WindowWidth / 9), Round(WindowHeight / 10.285), WindowWidth - Round(WindowWidth / 14.4), Round(WindowHeight / 3.6), 'Вы действительно хотите покинуть игру?');
  Rectangle(Round(WindowWidth / 3.272), WindowHeight - Round(WindowHeight / 3.6), Round(WindowWidth / 2.25), WindowHeight - Round(WindowHeight / 7.2));
  Rectangle(Round(WindowWidth / 1.945), WindowHeight - Round(WindowHeight / 3.6), Round(WindowWidth / 1.531), WindowHeight - Round(WindowHeight / 7.2));
  SetFontSize(Round(WindowHeight / 24));
  DrawTextCentered(Round(WindowWidth / 3.272), WindowHeight - Round(WindowHeight / 3.6), Round(WindowWidth / 2.25), WindowHeight - Round(WindowHeight / 7.2), 'Да');
  DrawTextCentered(Round(WindowWidth / 1.945), WindowHeight - Round(WindowHeight / 3.6), Round(WindowWidth / 1.531), WindowHeight - Round(WindowHeight / 7.2), 'Нет');
  UpdateWindow();
end;

procedure ExitWindow_MD(MouseX, MouseY, mouseButton: integer);
begin
  if (mouseButton = 1) and (MouseX > Round(WindowWidth / 3.272)) and (MouseY > WindowHeight - Round(WindowHeight / 3.6)) and (MouseX < Round(WindowWidth / 2.25)) and (MouseY < WindowHeight - Round(WindowHeight / 7.2)) then
  begin
    exit_window_show := false;
    exit_playing := true;
  end;
  
  if (mouseButton = 1) and (MouseX > Round(WindowWidth / 1.945)) and (MouseY > WindowHeight - Round(WindowHeight / 3.6)) and (MouseX < Round(WindowWidth / 1.531)) and (MouseY < WindowHeight - Round(WindowHeight / 7.2)) then
    exit_window_show := false;
end;


procedure ExitWindow_KD(key: integer);
begin
  if key = VK_Escape then exit_window_show := false;
  if key = VK_Enter then 
  begin
    exit_window_show := false;
    exit_playing := true;
  end;
end;

begin
  victory := false;
  lose := false;
  exit_playing := false;
end.
