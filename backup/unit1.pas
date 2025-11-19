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
    SQLQueryHeslo: TSQLQuery;
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



procedure TForm1.FormCreate(Sender: TObject);
begin
  // Připojení k databázi
  SQLite3Connection1.Connected := True;

  // Načtení pacientů
  SQLQueryPacient.Open;

  // Načtení výkonu
  SQLQueryVykon.Open;

  SQLQueryCekarna.Open;
end;


//  Při zmáčknutí tlačítka OK
procedure TForm1.PotvrdHesloClick(Sender: TObject);
var
  heslo: string;
  PacientID: Integer;
  jmeno: string;
  dalsiPoradi: Integer;
begin
  heslo := EditHeslo.Text;

  // Pokud člověk nic nezadá
  if heslo = '' then
  begin
    LabelInfo.Caption := 'Zadejte heslo!';
    Exit;
  end;


  // Ověření hesla
  SQLQueryHeslo.Close;
  SQLQueryHeslo.ParamByName('h').AsString := heslo;
  SQLQueryHeslo.Open;

  // Pokud zadá špatně
  if SQLQueryHeslo.IsEmpty then
  begin
    LabelInfo.Caption := 'Nesprávné heslo!';
    Exit;
  end;

  // Načtení informací
  PacientID := SQLQueryHeslo.FieldByName('PacientID').AsInteger;
  jmeno := SQLQueryHeslo.FieldByName('Jmeno').AsString;



  // Načtení pořadí
  SQLQueryCekarna.Close;
  SQLQueryCekarna.SQL.Text := 'SELECT COALESCE(MAX(Poradi), 0) + 1 AS dalsiPoradi FROM Cekarna';
  SQLQueryCekarna.Open;
  dalsiPoradi := SQLQueryCekarna.FieldByName('dalsiPoradi').AsInteger;

  // Vložíme pacienta do čekárny
  SQLQueryCekarna.Close;
  SQLQueryCekarna.SQL.Text := 'INSERT INTO Cekarna (PacientID, Jmeno, Poradi) VALUES (:pid, :jmeno, :poradi)';
  SQLQueryCekarna.ParamByName('pid').AsInteger := PacientID;
  SQLQueryCekarna.ParamByName('jmeno').AsString := jmeno;
  SQLQueryCekarna.ParamByName('poradi').AsInteger := dalsiPoradi;
  SQLQueryCekarna.ExecSQL;

  SQLTransaction1.CommitRetaining;

  // Znovu načteme čekárnu pro zobrazení
  SQLQueryCekarna.Close;
  SQLQueryCekarna.SQL.Text :=
    'SELECT Cekarna.Poradi, Cekarna.PacientID, Pacient.Jmeno ' +
    'FROM Cekarna ' +
    'JOIN Pacient ON Cekarna.PacientID = Pacient.PacientID ' +
    'ORDER BY Cekarna.Poradi';
  SQLQueryCekarna.Open;

  LabelInfo.Caption := 'Pacient ' + jmeno + ' přidán do čekárny (pořadí ' + IntToStr(dalsiPoradi) + ')';


end;


// Při zmáčknutí tlačítka Zadej heslo
procedure TForm1.ZadejHesloButtonClick(Sender: TObject);
begin
  EditHeslo.Visible := True;
  PotvrdHeslo.Visible := True;
  EditHeslo.SetFocus;
  LabelInfo.Caption := ''; // vyčistí případnou starou zprávu
end;



end.

