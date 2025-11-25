unit Unit2;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, SQLDB, DB, Forms, Controls, Graphics, Dialogs, DBGrids,
  StdCtrls, DBCtrls;

type

  { TSestra }

  TSestra = class(TForm)
    Button1: TButton;
    DataSourceVysetrovna: TDataSource;
    DataSourceVykon2: TDataSource;
    DBGrid2: TDBGrid;
    DBGrid3: TDBGrid;
    Vysetrovny: TDBLookupComboBox;
    SQLQueryVysetrovna: TSQLQuery;
    SQLQueryVykon2: TSQLQuery;
    procedure FormCreate(Sender: TObject);
    procedure ZavolatPacienta(Sender: TObject);

  private

  public

  end;

var
  Sestra: TSestra;

implementation
    uses Unit1;
{$R *.lfm}




{ TSestra }

procedure TSestra.FormCreate(Sender: TObject);
   begin

  // Načtení výkonu
  SQLQueryVykon2.Open;
  SQLQueryVysetrovna.Open;
end;

procedure TSestra.ZavolatPacienta(Sender: TObject);
    var
      jmenoPacienta: string;
    begin
      // Nejprve kontrola, zda je pacient vybrán
      if (not Pacient.DataSourceCekarna.DataSet.Active)
         or (Pacient.DataSourceCekarna.DataSet.IsEmpty) then
      begin
        ShowMessage('Není vybrán žádný pacient!');
        Exit;
      end;

      // Toto se provede jen pokud pacient vybrán je
      jmenoPacienta :=
        Pacient.DataSourceCekarna.DataSet.FieldByName('Jmeno').AsString;

      ShowMessage('Vybrán pacient: ' + jmenoPacienta);
    end;

    end.

