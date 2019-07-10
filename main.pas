Uses GraphABC, MineSweeper_game;

var app_is_running: boolean;

procedure Window_SetUp();
begin
  SetWindowSize(CellsInRow * CellSize, CellsInCol * CellSize);
  Window.CenterOnScreen;
  Window.Title := 'MineSweeper';
  Window.IsFixedSize := true;
end;

procedure Main_SetUp();
begin
  Window_SetUp();
  Init_Party();
  LockDrawing();
  OnMouseDown := MouseDown;
  app_is_running := true;
end;

procedure ExitApp();
begin
  app_is_running := false;
end;

begin
  Main_SetUp();
  while app_is_running do
  begin
    OnClose := ExitApp;
    Draw_Grid();
    CheckWon();
  end;
end.