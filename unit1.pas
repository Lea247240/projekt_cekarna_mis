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
SQLite3Connection1.Connected := True;

  SQLQueryPacient.SQL.Text := 'SELECT * FROM Pacient';
  SQLQueryPacient.Open;




end;




end.

