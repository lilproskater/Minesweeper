unit MineSweeper_game;

interface
Uses GraphABC, MineSweeper_Engine;

const CellsInCol = 16;
const CellsInRow = 16;
const bombsInGrid = 40;
const CellSize = MineSweeper_Engine.CellSize;

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

var grid: array [0..CellsInCol - 1, 0..CellsInRow - 1] of Cell; 

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
  if y_grid < CellsInCol - 1 then OpenCells(y_grid + 1, x_grid);
  if x_grid > 0 then OpenCells(y_grid, x_grid - 1);
  if x_grid < CellsInRow - 1 then OpenCells(y_grid, x_grid + 1);
  
  //Reveal nearby cells with nubmers
  if y_grid > 0 then if grid[y_grid - 1, x_grid].number <> 0 then grid[y_grid - 1, x_grid].Click(1);
  if y_grid < CellsInCol - 1 then if grid[y_grid + 1, x_grid].number <> 0 then grid[y_grid + 1, x_grid].Click(1);
  if x_grid > 0 then if grid[y_grid, x_grid - 1].number <> 0 then grid[y_grid, x_grid - 1].Click(1);
  if x_grid < CellsInRow - 1 then if grid[y_grid, x_grid + 1].number <> 0 then grid[y_grid, x_grid + 1].Click(1);
  if (y_grid > 0) and (x_grid > 0) then if grid[y_grid - 1, x_grid - 1].number <> 0 then grid[y_grid - 1, x_grid - 1].Click(1);
  if (y_grid > 0) and (x_grid < CellsInRow - 1) then if grid[y_grid - 1, x_grid + 1].number <> 0 then grid[y_grid - 1, x_grid + 1].Click(1);
  if (y_grid < CellsInCol - 1) and (x_grid > 0) then if grid[y_grid + 1, x_grid - 1].number <> 0 then grid[y_grid + 1, x_grid - 1].Click(1);
  if (y_grid < CellsInCol - 1) and (x_grid < CellsInRow - 1) then if grid[y_grid + 1, x_grid + 1].number <> 0 then grid[y_grid + 1, x_grid + 1].Click(1);
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
  for var y := 0 to CellsInCol - 1 do
    for var x := 0 to CellsInRow - 1 do
    begin
      grid[y, x] := new Cell(pos_x, pos_y, false);
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
    var y := Random(0, CellsInCol - 1);
    if not grid[y, x].contains_mine then grid[y, x].contains_mine := true
      else continue;
    bombs_counter -= 1;    
  end;
  
  //Setting Up Numbers
  for var y := 0 to CellsInCol - 1 do
    for var x := 0 to CellsInRow - 1 do
    begin
      var number := 0;
      if x > 0 then if grid[y, x - 1].contains_mine then number += 1;
      if y > 0 then if grid[y - 1, x].contains_mine then number += 1;
      if y < CellsInCol - 1 then if grid[y + 1, x].contains_mine then number += 1;
      if x < CellsInRow - 1 then if grid[y, x + 1].contains_mine then number += 1;
      if (x > 0) and (y > 0) then if grid[y - 1, x - 1].contains_mine then number += 1;
      if (y > 0) and (x < CellsInRow - 1) then if grid[y - 1, x + 1].contains_mine then number += 1;
      if (y < CellsInCol - 1) and (x > 0) then if grid[y + 1, x - 1].contains_mine then number += 1;
      if (y < CellsInCol - 1) and (x < CellsInRow - 1) then if grid[y + 1, x + 1].contains_mine then number += 1;
      grid[y, x].number := number;
    end;
end;

procedure GameMouseDown(MouseX, MouseY, mouseButton: integer);
begin
  if not (lose) and not (victory) then
  begin
    var y := Trunc(MouseY / (WindowHeight / CellsInCol));
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
    if (mouseButton = 1) and (MouseX > 20) and (MouseY > WindowHeight - 120) and (MouseX < 120) and (MouseY < WindowHeight - 20) then exit_playing := true;
    if (mouseButton = 1) and (MouseX > 170) and (MouseY > WindowHeight - 120) and (MouseX < 270) and (MouseY < WindowHeight - 20) then Init_Party();
  end; 
end;

procedure Draw_Grid();
begin
  SetPenWidth(1);
  SetPenColor(rgb(0, 0, 0));
  for var y := 0 to CellsInCol - 1 do
    for var x := 0 to CellsInRow - 1 do
      grid[y, x].Draw();
  if lose then
  begin
    SetFontColor(clRed);
    SetFontSize(100);
    DrawTextCentered(0, 0, WindowWidth, WindowHeight, 'You Lose!');
    SetFontSize(50);
    SetPenWidth(7);
    SetPenColor(rgb(255, 255, 255));
    SetBrushColor(rgb(185, 185, 185));
    Rectangle(20, WindowHeight - 120, 120, WindowHeight - 20);
    Rectangle(170, WindowHeight - 120, 270, WindowHeight - 20);
    SetFontColor(rgb(255, 255, 255));
    DrawTextCentered(20, WindowHeight - 120, 120, WindowHeight - 20, '←');
    DrawTextCentered(170, WindowHeight - 120, 270, WindowHeight - 20, '►');
  end;
  if victory then
  begin
    SetFontColor(clLime);
    SetFontSize(100);
    DrawTextCentered(0, 0, WindowWidth, WindowHeight, 'You Won!');
    SetFontSize(50);
    SetPenWidth(7);
    SetPenColor(rgb(255, 255, 255));
    SetBrushColor(rgb(185, 185, 185));
    Rectangle(20, WindowHeight - 120, 120, WindowHeight - 20);
    Rectangle(170, WindowHeight - 120, 270, WindowHeight - 20);
    SetFontColor(rgb(255, 255, 255));
    DrawTextCentered(20, WindowHeight - 120, 120, WindowHeight - 20, '←');
    DrawTextCentered(170, WindowHeight - 120, 270, WindowHeight - 20, '►');
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
    for var y := 0 to CellsInCol - 1 do
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
  SetPenWidth(7);
  Rectangle(50, 50, WindowWidth - 50, WindowHeight - 50);
  SetFontSize(35);
  DrawTextCentered(80, 70, WindowWidth - 50, 200, 'Вы действительно хотите покинуть игру?');
  Rectangle(220, WindowHeight - 200, 320, WindowHeight - 100);
  Rectangle(370, WindowHeight - 200, 470, WindowHeight - 100);
  SetFontSize(30);
  DrawTextCentered(220, WindowHeight - 200, 320, WindowHeight - 100, 'Да');
  DrawTextCentered(370, WindowHeight - 200, 470, WindowHeight - 100, 'Нет');
  UpdateWindow();
end;

procedure ExitWindow_MD(MouseX, MouseY, mouseButton: integer);
begin
  if (mouseButton = 1) and (MouseX > 220) and (MouseY > WindowHeight - 200) and (MouseX < 320) and (MouseY < WindowHeight - 100) then
  begin
    exit_window_show := false;
    exit_playing := true;
  end;
  
  if (mouseButton = 1) and (MouseX > 370) and (MouseY > WindowHeight - 200) and (MouseX < 470) and (MouseY < WindowHeight - 100) then
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