Uses GraphABC, Menues, MineSweeper_game;

var app_is_running: boolean;

procedure Window_SetUp();
begin
  SetWindowSize(Width, Height);
  Window.CenterOnScreen;
  Window.Title := 'MineSweeper';
  Window.IsFixedSize := true;
  OnClose := halt;
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
      OnKeyUp := MainMenu_KU;
      MainMenu_Interface();
      while playing do
      begin
        OnMouseDown := GameMouseDown;
        OnKeyUp := GameKeyDown;
        CheckGameStatus();
        Drawer();
        if exit_playing then playing := false;
      end;
      while statistics do
      begin
        OnMouseDown := Statistics_MD;
        OnKeyUp := Statistics_KU;
        Statistics_Interface();
      end;
      while settings do
      begin
        OnMouseDown := Settings_MD;
        OnKeyUp := Settings_KU;
        Settings_Interface();
      end;
      if quit then halt();
    end;
  end;
end.
