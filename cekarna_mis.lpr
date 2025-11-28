program cekarna_mis;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  {$IFDEF HASAMIGA}
  athreads,
  {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, Unit1, Unit2, Unit3, Unit4, Unit5
  { you can add units after this };

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Scaled:=True;
  {$PUSH}{$WARN 5044 OFF}
  Application.MainFormOnTaskbar:=True;
  {$POP}
  Application.Initialize;
  Application.CreateForm(TPacient, Pacient);
  Application.CreateForm(TSestra, Sestra);
  Application.CreateForm(TObjednaniPacienti, ObjednaniPacienti);
  Application.CreateForm(TVysetrovny, Vysetrovny);
  Application.CreateForm(TAutori, Autori);
  Application.Run;
end.

