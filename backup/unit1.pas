unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, SQLite3Conn, SQLDB, DB, Forms, Controls, Graphics, Dialogs,
  StdCtrls, DBGrids;

type

  { TForm1 }

  TForm1 = class(TForm)
    DataSourceVykon: TDataSource;
    DataSourcePacient: TDataSource;
    DBGrid1: TDBGrid;
    DBGrid2: TDBGrid;
    SQLite3Connection1: TSQLite3Connection;
    SQLQueryCekarna: TSQLQuery;
    SQLQueryVykon: TSQLQuery;
    SQLQueryPacient: TSQLQuery;
    SQLTransaction1: TSQLTransaction;
    procedure DataSourcePacientDataChange(Sender: TObject; Field: TField);
    procedure FormCreate(Sender: TObject);
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

  // --- Master: všichni pacienti ---
  SQLQueryPacient.SQL.Text := 'SELECT * FROM Pacient';
  SQLQueryPacient.Open;

  // --- Vytvoření tabulky Cekarna, pokud neexistuje ---
  SQLQueryCekarna.SQL.Text :=
    'CREATE TABLE IF NOT EXISTS Cekarna (' +
    'CekarnaID INTEGER PRIMARY KEY AUTOINCREMENT,' +
    'PacientID INTEGER NOT NULL,' +
    'Poradi INTEGER NOT NULL,' +
    'FOREIGN KEY (PacientID) REFERENCES Pacient(PacientID)' +
    ');';
  SQLQueryCekarna.ExecSQL;
  SQLTransaction1.Commit;

  // --- Načtení čekárny s jménem pacienta a pořadím ---
  SQLQueryCekarna.SQL.Text :=
    'SELECT Pacient.Jmeno, Cekarna.Poradi ' +
    'FROM Cekarna ' +
    'JOIN Pacient ON Cekarna.PacientID = Pacient.PacientID ' +
    'ORDER BY Cekarna.Poradi;';
  SQLQueryCekarna.Open;
end;





end.

