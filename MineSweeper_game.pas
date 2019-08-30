unit MineSweeper_game;

interface

Uses GraphABC, MineSweeper_Engine, System.Threading;

const StatusBarSize = Round(ScreenHeight / 11.25);
const Database = 'data/data.dat';

var
  victory, lose, exit_playing: boolean;
  Width, Height: integer;

procedure Setup();
procedure Init_Party();
procedure GameMouseDown(MouseX, MouseY, mouseButton: integer);
procedure GameKeyDown(key: integer);
procedure CheckGameStatus();
procedure Drawer();

implementation
var
  bombsInGrid, CellSize, CellsInRow: integer;
  score, played_seconds: integer;
  best_score, best_time: integer;
  message: string;
  show_exit_window: boolean;
  timer_thread: Thread;
  grid: array [, ] of Cell;
  filer: text;

//-----------------------------  Private: Update Window  -----------------------------//
procedure UpdateWindow();
begin
  try
    Redraw();
  except
  
  end;
end;
//-----------------------------------------------------------------------//


//-----------------------------  Private: Count Seconds  -----------------------------//
procedure Count_Seconds();
begin
  while true do
  begin
    sleep(1000);
    if not (show_exit_window) and not(lose) and not (victory) then played_seconds += 1;
  end;
end;
//-----------------------------------------------------------------------//


//-----------------------------  Private: Count Flags  -----------------------------//
function CountFlags(): integer;
var
  counter: integer;
begin
  for var y := 0 to CellsInRow - 1 do
    for var x := 0 to CellsInRow - 1 do
    try // Because Not all objects might be initialized yet
      if grid[y, x].flag_is_put then counter += 1;
    except
    end;
  result := counter;
end;
//-----------------------------------------------------------------------//


//-----------------------------  Private: Get Score  -----------------------------//
function GetScore(): integer;
var
  counter: integer;
begin
  for var y := 0 to CellsInRow - 1 do
    for var x := 0 to CellsInRow - 1 do
    try // Because Not all objects might be initialized yet
      if (grid[y, x].revealed) and not (grid[y, x].contains_mine) then counter += 50;
    except
    end;
  result := counter;
end;
//-----------------------------------------------------------------------//


//-----------------------------  Private: Open Cells Recursively  -----------------------------//
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
//-----------------------------------------------------------------------//


//-----------------------------  Private: Rewrite file  -----------------------------//
procedure Rewrite_file();
begin
  Rewrite(filer, Database);
  filer.Writeln(max(best_score, score));
  if victory then filer.Writeln(min(best_time, played_seconds))
  else filer.Writeln(best_time);
  filer.Close();
end;
//-----------------------------------------------------------------------//


//-----------------------------  Setup -----------------------------//
procedure Setup();
begin
  CellsInRow := 16;
  //Edit CellsInRow by file when Settings are done
  CellSize := Round(ScreenHeight / CellsInRow / 1.4);
  bombsInGrid := Round(Sqr(CellsInRow) / 6.4);
  grid := new Cell[CellsInRow, CellsInRow];
  victory := false;
  lose := false;
  exit_playing := false;
  first_click := true;
  mine_is_pressed := false;
  played_seconds := 0;
  score := 0;
  best_score := 0;
  best_time := 99999999;
  message := '';
end;
//-----------------------------------------------------------------------//


//-----------------------------  Initialize Party  -----------------------------//
procedure Init_Party();
begin
  try //Because file may not exsist
    Reset(filer, Database);
    var best_score_handler, best_time_handler: string;
    Readln(filer, best_score_handler);
    Readln(filer, best_time_handler);
    filer.Close();
    best_score := best_score_handler.ToInteger;
    best_time := best_time_handler.ToInteger;
  except 
    
  end;
  //Firstly setting all cells empty
  //Setting x and y positions for each cell
  for var y := 0 to CellsInRow - 1 do
    for var x := 0 to CellsInRow - 1 do
      grid[y, x] := new Cell(x * CellSize, y * CellSize + StatusBarSize, (x + 1) * CellSize, (y + 1) * CellSize + StatusBarSize, false);
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
//-----------------------------------------------------------------------//


//-----------------------------  Game Mouse Down  -----------------------------//
procedure GameMouseDown(MouseX, MouseY, mouseButton: integer);
begin
  if MouseY <= StatusBarSize then exit;
  if not (lose) and not (victory) then
  begin
    var y := Trunc((MouseY - StatusBarSize) / CellSize);
    var x := Trunc(MouseX / CellSize);
    if mouseButton = 1 then
    begin
      if (grid[y, x].number <> 0) or (grid[y, x].contains_mine) then grid[y, x].Click(1)
      else if not grid[y, x].flag_is_put then OpenCells(y, x);
      if first_click then 
      begin
        first_click := false;
        timer_thread := new Thread(Count_Seconds);
        timer_thread.Start();
        if mine_is_pressed then
        begin
          mine_is_pressed := false;
          while grid[y, x].contains_mine do
            Init_Party();
          if grid[y, x].number <> 0 then grid[y, x].Click(1)
          else OpenCells(y, x); 
        end;
      end;
      score := GetScore();
    end
    else 
    begin
      if not first_click then grid[y, x].Click(mouseButton)
      else message := 'Сначала откройте клетку поля!';
    end;
  end
  else
  begin
    if (mouseButton = 1) and (MouseX > Round(Width / 36)) and (MouseY > Height - Round(Height / 6)) and (MouseX < Round(Width / 6)) and (MouseY < Height - Round(Height / 36)) then 
    begin
      Rewrite_file();
      timer_thread.Abort();
      exit_playing := true;
    end;
    if (mouseButton = 1) and (MouseX > Round(Width / 4.235)) and (MouseY > Height - Round(Height / 6)) and (MouseX < Round(Width / 2.666)) and (MouseY < Height - Round(Height / 36)) then 
    begin
      Rewrite_file();
      timer_thread.Abort();
      SetUp();
      Init_Party();
    end;
  end; 
end;
//-----------------------------------------------------------------------//


//-----------------------------  Game Key Down  -----------------------------//
procedure GameKeyDown(key: integer);
begin
  if (key = VK_Escape) and not (lose) and not (victory) then show_exit_window := true
  else show_exit_window := false;
  if (key = VK_Escape) and ((lose) or (victory)) then
  begin
    Rewrite_file();
    timer_thread.Abort();
    exit_playing := true;
  end;
  if (key = VK_Enter) and ((lose) or (victory)) then
  begin
    Rewrite_file();
    timer_thread.Abort();
    SetUp();
    Init_Party();
  end;
end;
//-----------------------------------------------------------------------//


//-----------------------------  Check Game Status  -----------------------------//
procedure CheckGameStatus();
begin
  if mine_is_pressed then
    lose := true
  else
  begin
    var count_unrevealed := 0;
    for var y := 0 to CellsInRow - 1 do
      for var x := 0 to CellsInRow - 1 do
        try // Because Not all objects might be initialized yet
          if not grid[y, x].revealed then count_unrevealed += 1;
        except
        end;
    if count_unrevealed = bombsInGrid then victory := true;
  end;
end;
//-----------------------------------------------------------------------//


//-----------------------------  Exit Window Interface  -----------------------------//
procedure ExitWindow_Interface();
begin
  SetPenColor(rgb(255, 255, 255));
  SetBrushColor(rgb(185, 185, 185));
  SetFontColor(rgb(255, 255, 255));
  SetPenWidth(Round(Height / 102.835));
  var HalfStatusBar :=  Round(StatusBarSize / 2);
  Rectangle(Round(Width / 14.4), Round(Height / 14.4) + HalfStatusBar, Width - Round(Width / 14.4), Height - Round(Height / 14.4) - HalfStatusBar);
  SetFontSize(Round(Height / 20.571));
  DrawTextCentered(Round(Width / 9), Round(Height / 10.285) + HalfStatusBar, Width - Round(Width / 14.4), Round(Height / 3.6) + HalfStatusBar, 'Вы действительно хотите покинуть игру?');
  Rectangle(Round(Width / 3.272), Height - Round(Height / 3.2), Round(Width / 2.25), Height - Round(Height / 5.5));
  Rectangle(Round(Width / 1.945), Height - Round(Height / 3.2), Round(Width / 1.531), Height - Round(Height / 5.5));
  SetFontSize(Round(Height / 24));
  DrawTextCentered(Round(Width / 3.272), Height - Round(Height / 3.2), Round(Width / 2.25), Height - Round(Height / 5.5), 'Да');
  DrawTextCentered(Round(Width / 1.945), Height - Round(Height / 3.2), Round(Width / 1.531), Height - Round(Height / 5.5), 'Нет');
  UpdateWindow();
end;
//-----------------------------------------------------------------------//


//-----------------------------  Exit Window Mouse Down  -----------------------------//
procedure ExitWindow_MD(MouseX, MouseY, mouseButton: integer);
begin
  if (mouseButton = 1) and (MouseX > Round(Width / 3.272)) and (MouseY > Height - Round(Height / 3.2)) and (MouseX < Round(Width / 2.25)) and (MouseY < Height - Round(Height / 5.5)) then
  begin
    show_exit_window := false;
    exit_playing := true;
    timer_thread.Abort();
  end;
  
  if (mouseButton = 1) and (MouseX > Round(Width / 1.945)) and (MouseY > Height - Round(Height / 3.2)) and (MouseX < Round(Width / 1.531)) and (MouseY < Height - Round(Height / 5.5)) then
    show_exit_window := false;
end;
//-----------------------------------------------------------------------//


//-----------------------------  Exit Window Key Down  -----------------------------//
procedure ExitWindow_KD(key: integer);
begin
  if key = VK_Escape then show_exit_window := false;
  if key = VK_Enter then 
  begin
    show_exit_window := false;
    exit_playing := true;
    timer_thread.Abort();
  end;
end;
//-----------------------------------------------------------------------//


//-----------------------------  Drawer  -----------------------------//
procedure Drawer();
begin
  //Status Bar
  SetPenWidth(1);
  SetPenColor(rgb(0, 0, 0));
  SetBrushColor(rgb(140, 140, 140));
  Rectangle(0, 0, Width, StatusBarSize);
  //Grid
  for var y := 0 to CellsInRow - 1 do
    for var x := 0 to CellsInRow - 1 do
    try // Because Not all objects might be initialized yet
      grid[y, x].Draw();
    except
    end;
 
  //Status Bar Items
  SetFontSize(Round(ScreenHeight / 45));
  SetBrushColor(rgb(0, 0, 0));
  SetPenWidth(4);
  SetPenColor(rgb(255, 255, 255));
  Rectangle(Round(Width / 64), Round(Height / 72), Round(Width / 4), StatusBarSize - Round(Height / 72));
  Rectangle(Width - Round(Width / 4), Round(Height / 72), Width - Round(Width / 64), StatusBarSize - Round(Height / 72));
  Rectangle(Round(Width / 2.612), Round(Height / 72), Round(Width / 1.620), StatusBarSize - Round(Height / 24));
  SetFontColor(rgb(255, 0, 0));
  DrawTextCentered(Round(Width / 64), Round(Height / 72), Round(Width / 4), StatusBarSize - Round(Height / 72), played_seconds);
  DrawTextCentered(Width - Round(Width / 4), Round(Height / 72), Width - Round(Width / 64), StatusBarSize - Round(Height / 72), bombsInGrid - CountFlags());
  DrawTextCentered(Round(Width / 2.612), Round(Height / 72), Round(Width / 1.620), StatusBarSize - Round(Height / 24), score);
  SetFontColor(rgb(255, 255, 255));
  SetFontSize(Round(ScreenHeight / 64.285));
  DrawTextCentered(Round(Width / 4), StatusBarSize - Round(Height / 24), Width - Round(Width / 4), StatusBarSize, message);
  while show_exit_window do
  begin
    OnMouseDown := ExitWindow_MD;
    OnKeyDown := ExitWindow_KD;
    ExitWindow_Interface();
  end;
  
  if (lose) or (victory) then
  begin
    timer_thread.Abort();
    ClearWindow(argb(130, 40, 40, 40));
    var new_best := '';
    var new_best_score := score > best_score;
    SetFontSize(Round(Height / 14.5));
    if new_best_score then new_best := 'Новый рекорд!';
    if lose then
    begin
      SetFontColor(rgb(255, 0, 0));
      DrawTextCentered(0, 0, Width, Height, 'Вы проиграли!');
    end;
    if victory then
    begin
      var new_best_time := played_seconds < best_time;
      if new_best_time then new_best := 'Новое лучшее время!';
      if (new_best_score) and (new_best_time) then new_best := 'Новый рекорд и лучшее время!';
      SetFontColor(clLime);
      DrawTextCentered(0, 0, Width, Height, 'Вы выиграли!');
    end;
    SetFontColor(rgb(255, 255, 255));
    SetFontSize(Round(ScreenHeight / 35));
    DrawTextCentered(0, Round(Height / 6), Width, Height, new_best);
    SetFontSize(Round(Height / 14.4));
    SetPenWidth(Round(Height / 102.857));
    SetPenColor(rgb(255, 255, 255));
    SetBrushColor(rgb(185, 185, 185));
    Rectangle(Round(Width / 36), Height - Round(Height / 6), Round(Width / 6), Height - Round(Height / 36));
    Rectangle(Round(Width / 4.235), Height - Round(Height / 6), Round(Width / 2.666), Height - Round(Height / 36));
    SetFontColor(rgb(255, 255, 255));
    DrawTextCentered(Round(Width / 36), Height - Round(Height / 6), Round(Width / 6), Height - Round(Height / 36), '←');
    DrawTextCentered(Round(Width / 4.235), Height - Round(Height / 6), Round(Width / 2.666), Height - Round(Height / 36), '►');
  end;
  UpdateWindow();
end;
//-----------------------------------------------------------------------//

begin
  Setup();
  Width := CellSize * CellsInRow;
  Height := Width + StatusBarSize;
end.
