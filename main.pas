Uses GraphABC, MineSweeper_game, Menues;

var app_is_running: boolean;

procedure Window_SetUp();
begin
  SetWindowSize(CellSize * CellsInRow, CellSize * CellsInRow);
  Window.CenterOnScreen;
  Window.Title := 'MineSweeper';
  Window.IsFixedSize := true;
end;

procedure Main_SetUp();
begin
  Window_SetUp();
  app_is_running := true;
  main_menu := true;
  LockDrawing();
end;

begin
  Main_SetUp();
  while app_is_running do
  begin
    while main_menu do
    begin
      OnMouseDown := MainMenu_MD;
      OnKeyDown := MainMenu_KD;
      MainMenu_Interface();
      while playing do
      begin
        OnMouseDown := GameMouseDown;
        OnKeyDown := GameKeyDown;
        Draw_Grid();
        CheckGameStatus();
        while exit_window_show do
        begin
          OnMouseDown := ExitWindow_MD;
          OnKeyDown := ExitWindow_KD;
          ExitWindow_Interface();
        end;
        if exit_playing then playing := false;
      end;
      while statistics do
      begin
        OnMouseDown := Statistics_MD;
        OnKeyDown := Statistics_KD;
        Statistics_Interface();
      end;
      while settings do
      begin
        OnMouseDown := Settings_MD;
        OnKeyDown := Settings_KD;
        Settings_Interface();
      end;
      if quit then halt();
    end;
  end;
end.
