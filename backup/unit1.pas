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
begin
  heslo := EditHeslo.Text;

  // Pokud člověk nic nezadá
  if heslo = '' then
  begin
    LabelInfo.Caption := 'Zadejte heslo!';
    Exit;
  end;


SQLQueryHeslo.Close;
  SQLQueryHeslo.ParamByName('h').AsString := heslo;
  SQLQueryHeslo.Open;

  if SQLQueryHeslo.IsEmpty then
  begin
    LabelInfo.Caption := 'Nesprávné heslo!';
    Exit;
  end;

  PacientID := SQLQueryHeslo.FieldByName('PacientID').AsInteger;
  jmeno := SQLQueryHeslo.FieldByName('Jmeno').AsString;

  LabelInfo.Caption := 'Pacient: ' + jmeno + ', ID: ' + IntToStr(PacientID);

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

