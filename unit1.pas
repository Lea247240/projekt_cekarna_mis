unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, SQLite3Conn, SQLDB, DB, Forms, Controls, Graphics, Dialogs,
  StdCtrls, DBGrids, ExtCtrls;

type

  { TPacient }

  TPacient = class(TForm)
    Button1: TButton;
    LabelDalsi: TLabel;
    LabelInfo: TLabel;
    PotvrdHeslo: TButton;
    EditHeslo: TEdit;
    SQLQueryCekarnaInsert: TSQLQuery;
    SQLQueryHeslo: TSQLQuery;
    ZadejHesloButton: TButton;
    DataSourceCekarna: TDataSource;
    DataSourceVykon: TDataSource;
    DataSourcePacient: TDataSource;
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
    procedure NastavitDalsiNaRade(const s: string);

  end;

var
  Pacient: TPacient;
  PosledniPoradi: Integer = 0;

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

  // Načtení posledního použitého pořadí
  SQLQueryCekarna.Last; // nebo SQL dotaz: SELECT MAX(Poradi) AS MaxPoradi FROM Cekarna;
  if not SQLQueryCekarna.IsEmpty then
    PosledniPoradi := SQLQueryCekarna.FieldByName('Poradi').AsInteger
  else
    PosledniPoradi := 0;



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


  PosledniPoradi := PosledniPoradi + 1;
  dalsiPoradi := PosledniPoradi;

  // Výpočet pořadí pomocí SQLQueryCekarnaInsert
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


procedure TPacient.NastavitDalsiNaRade(const s: string);
begin
  LabelDalsi.Caption := s;
end;



end.

