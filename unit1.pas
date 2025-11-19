unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, SQLite3Conn, SQLDB, DB, Forms, Controls, Graphics, Dialogs,
  StdCtrls, DBGrids;

type

  { TPacient }

  TPacient = class(TForm)
    Button1: TButton;
    LabelInfo: TLabel;
    PotvrdHeslo: TButton;
    EditHeslo: TEdit;
    SQLQueryCekarnaInsert: TSQLQuery;
    SQLQueryHeslo: TSQLQuery;
    ZadejHesloButton: TButton;
    DataSourceCekarna: TDataSource;
    DataSourceVykon: TDataSource;
    DataSourcePacient: TDataSource;
    DBGrid1: TDBGrid;
    DBGrid2: TDBGrid;
    SQLite3Connection1: TSQLite3Connection;
    SQLQueryCekarna: TSQLQuery;
    SQLQueryVykon: TSQLQuery;
    SQLQueryPacient: TSQLQuery;
    SQLTransaction1: TSQLTransaction;
    procedure OtevriSestru(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure PotvrdHesloClick(Sender: TObject);
    procedure ZadejHesloButtonClick(Sender: TObject);
  private

  public

  end;

var
  Pacient: TPacient;

implementation
    uses
      Unit2;
{$R *.lfm}

{ TPacient }



procedure TPacient.FormCreate(Sender: TObject);
begin
  // Připojení k databázi
  SQLite3Connection1.Connected := True;

  // Načtení pacientů
  SQLQueryPacient.Open;

  // Načtení výkonu
  SQLQueryVykon.Open;

  SQLQueryCekarna.Open;
end;

procedure TPacient.OtevriSestru(Sender: TObject);
begin
   Sestra.Show;
end;


//  Při zmáčknutí tlačítka OK
procedure TPacient.PotvrdHesloClick(Sender: TObject);
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



  // Výpočet pořadí pomocí SQLQueryCekarnaInsert
  SQLQueryCekarnaInsert.Close;
  SQLQueryCekarnaInsert.SQL.Text :=
    'SELECT COALESCE(MAX(Poradi), 0) + 1 AS dalsiPoradi FROM Cekarna';
  SQLQueryCekarnaInsert.Open;

  dalsiPoradi := SQLQueryCekarnaInsert.FieldByName('dalsiPoradi').AsInteger;

  // INSERT pacienta do čekárny – opět přes SQLQueryCekarnaInsert
  SQLQueryCekarnaInsert.Close;
  SQLQueryCekarnaInsert.SQL.Text :=
    'INSERT INTO Cekarna (PacientID, Jmeno, Poradi) ' +
    'VALUES (:pid, :jmeno, :poradi)';
  SQLQueryCekarnaInsert.ParamByName('pid').AsInteger := PacientID;
  SQLQueryCekarnaInsert.ParamByName('jmeno').AsString := jmeno;
  SQLQueryCekarnaInsert.ParamByName('poradi').AsInteger := dalsiPoradi;
  SQLQueryCekarnaInsert.ExecSQL;

  SQLTransaction1.CommitRetaining;

  // Znovu načteme čekárnu pro zobrazení
  SQLQueryCekarna.Close;
  SQLQueryCekarna.Open;

  LabelInfo.Caption := 'Pacient ' + jmeno + ' přidán do čekárny (pořadí ' + IntToStr(dalsiPoradi) + ')';


end;


// Při zmáčknutí tlačítka Zadej heslo
procedure TPacient.ZadejHesloButtonClick(Sender: TObject);
begin
  EditHeslo.Visible := True;
  PotvrdHeslo.Visible := True;
  EditHeslo.SetFocus;
  LabelInfo.Caption := ''; // vyčistí případnou starou zprávu
end;



end.

