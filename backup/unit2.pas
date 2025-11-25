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
    DBLookupComboBox1: TDBLookupComboBox;
    SQLQueryDeleteCekarna: TSQLQuery;
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
  DBLookupComboBox1.ListSource := DataSourceVysetrovna;
  DBLookupComboBox1.ListField := 'Cislo';
  DBLookupComboBox1.KeyField := 'VysetrovnaID';
end;

procedure TSestra.ZavolatPacienta(Sender: TObject);
var
  jmenoPacienta: string;
  cisloVysetrovny: string;
  odpoved: Integer;
  pacID: Integer;
begin
  if (not Pacient.DataSourceCekarna.DataSet.Active) or (Pacient.DataSourceCekarna.DataSet.IsEmpty) then
  begin
    ShowMessage('Není vybrán žádný pacient!');
    Exit;
  end;

  if DBLookupComboBox1.KeyValue = Null then
  begin
    ShowMessage('Není vybrána vyšetřovna!');
    Exit;
  end;

  jmenoPacienta := Pacient.DataSourceCekarna.DataSet.FieldByName('Jmeno').AsString;
  cisloVysetrovny := DBLookupComboBox1.Text;

  pacID := Pacient.DataSourceCekarna.DataSet.FieldByName('PacientID').AsInteger;


  odpoved := MessageDlg(
    'Opravdu si přejete zavolat pacienta ' + jmenoPacienta + ' do vyšetřovny číslo ' + cisloVysetrovny + '?',
    mtConfirmation,
    [mbYes, mbNo],
    0
  );

  if odpoved = mrYes then
  begin
    // DELETE přes nový SQLQuery
    SQLQueryDeleteCekarna.Close;
    SQLQueryDeleteCekarna.SQL.Text := 'DELETE FROM Cekarna WHERE PacientID = :id';
    SQLQueryDeleteCekarna.Params.ParamByName('id').AsInteger := pacID;
    SQLQueryDeleteCekarna.ExecSQL;
    SQLTransactionCekarna.Commit; // uloží změnu do DB

    ShowMessage('Pacient ' + jmenoPacienta + ' byl vyzván do vyšetřovny ' + cisloVysetrovny + '.');

    // Obnovíme hlavní dataset, aby zmizel ze seznamu
    SQLQueryCekarna.Close;
    SQLQueryCekarna.Open;
  end
  else
    ShowMessage('Volání pacienta zrušeno.');
end;


    end.

