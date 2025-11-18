unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, SQLite3Conn, SQLDB, DB, Forms, Controls, Graphics, Dialogs,
  StdCtrls, DBGrids;

type

  { TForm1 }

  TForm1 = class(TForm)
    LabelInfo: TLabel;
    PotvrdHeslo: TButton;
    EditHeslo: TEdit;
    ZadejHesloButton: TButton;
    DataSourceCekarna: TDataSource;
    DataSourceVykon: TDataSource;
    DataSourcePacient: TDataSource;
    DBGrid1: TDBGrid;
    DBGrid2: TDBGrid;
    DBGrid3: TDBGrid;
    SQLite3Connection1: TSQLite3Connection;
    SQLQueryCekarna: TSQLQuery;
    SQLQueryVykon: TSQLQuery;
    SQLQueryPacient: TSQLQuery;
    SQLTransaction1: TSQLTransaction;
    procedure DataSourcePacientDataChange(Sender: TObject; Field: TField);
    procedure FormCreate(Sender: TObject);
    procedure PotvrdHesloClick(Sender: TObject);
    procedure ZadejHesloButtonClick(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }



procedure TForm1.DataSourcePacientDataChange(Sender: TObject; Field: TField);
begin
    if not SQLQueryPacient.IsEmpty then
    begin
      SQLQueryVykon.Close;
      SQLQueryVykon.ParamByName('PacientID').AsInteger :=
        SQLQueryPacient.FieldByName('PacientID').AsInteger;
      SQLQueryVykon.Open;
    end
    else
      SQLQueryVykon.Close;
  end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  // Připojení k databázi
  SQLite3Connection1.Connected := True;

  // Načtení pacientů
  SQLQueryPacient.Open;


  // --- Načtení čekárny ---
  SQLQueryCekarna.Open;
end;

procedure TForm1.PotvrdHesloClick(Sender: TObject);
var
  heslo: string;
  PacientID: Integer;
  jmeno: string;
  tempQuery: TSQLQuery;
begin
  heslo := EditHeslo.Text;
  if heslo = '' then
  begin
    LabelInfo.Caption := 'Zadejte heslo!';
    Exit;
  end;

  // --- Lokální query pro ověření hesla ---
  tempQuery := TSQLQuery.Create(nil);
  try
    tempQuery.DataBase := SQLite3Connection1;
    tempQuery.SQL.Text := 'SELECT PacientID, Jmeno FROM Pacient WHERE Heslo = :h';
    tempQuery.ParamByName('h').AsString := heslo;
    tempQuery.Open;

    if tempQuery.IsEmpty then
    begin
      LabelInfo.Caption := 'Nesprávné heslo!';
      Exit;
    end;

    PacientID := tempQuery.FieldByName('PacientID').AsInteger;
    jmeno := tempQuery.FieldByName('Jmeno').AsString;

    LabelInfo.Caption := 'Pacient: ' + jmeno + ', ID: ' + IntToStr(PacientID);

  finally
    tempQuery.Free;
  end;
end;



procedure TForm1.ZadejHesloButtonClick(Sender: TObject);
begin
  EditHeslo.Visible := True;
  PotvrdHeslo.Visible := True;
  EditHeslo.SetFocus;
  LabelInfo.Caption := ''; // vyčistí případnou starou zprávu
end;





end.

