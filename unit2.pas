unit Unit2;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, SQLDB, DB, Forms, Controls, Graphics, Dialogs, DBGrids,
  StdCtrls, DBCtrls, Menus;

type

  { TSestra }

  TSestra = class(TForm)
    Button1: TButton;
    DataSourceVysetrovna: TDataSource;
    DataSourceVykon2: TDataSource;
    DBGrid2: TDBGrid;
    DBGrid3: TDBGrid;
    DBLookupComboBox1: TDBLookupComboBox;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    SQLQueryDeleteCekarna: TSQLQuery;
    SQLQueryVysetrovna: TSQLQuery;
    SQLQueryVykon2: TSQLQuery;
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure NovyDen(Sender: TObject);
    procedure UkazatObjednane(Sender: TObject);
    procedure UkazatVysetrovny(Sender: TObject);
    procedure ZavolatPacienta(Sender: TObject);


  private

  public
    procedure ZobrazOkno;
  end;

var
  Sestra: TSestra;

implementation
    uses Unit1, Unit3, Unit4;
{$R *.lfm}




{ TSestra }

procedure TSestra.FormCreate(Sender: TObject);
   begin

  SQLQueryVykon2.Open;
  SQLQueryVysetrovna.Open;
  DBLookupComboBox1.ListSource := DataSourceVysetrovna;
  DBLookupComboBox1.ListField := 'Cislo';
  DBLookupComboBox1.KeyField := 'VysetrovnaID';
end;


procedure TSestra.ZobrazOkno;
   begin
     if WindowState = wsMinimized then
       WindowState := wsNormal;

     Show;
     BringToFront;
     SetFocus;
   end;

procedure TSestra.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (ssCtrl in Shift) and (Key = Ord('P')) then
  begin
    Hide;
    Pacient.ZobrazOkno;
    Key := 0;
  end;

end;

procedure TSestra.NovyDen(Sender: TObject);
begin
  // vymazání čekárny
  SQLQueryDeleteCekarna.Close;
  SQLQueryDeleteCekarna.SQL.Text := 'DELETE FROM Cekarna';
  SQLQueryDeleteCekarna.ExecSQL;
  Pacient.SQLTransaction1.CommitRetaining;

  // zavření a znovuotevření datasetů
  SQLQueryVysetrovna.Close;
  SQLQueryVykon2.Close;
  SQLQueryVysetrovna.Open;
  SQLQueryVykon2.Open;

  Pacient.SQLQueryCekarna.Close;
  Pacient.SQLQueryCekarna.Open;
  PosledniPoradi := 0;

end;

procedure TSestra.UkazatObjednane(Sender: TObject);
begin
  ObjednaniPacienti := TObjednaniPacienti.Create(Self);
  ObjednaniPacienti.Show;  // nebo ShowModal pro modální okno
end;

procedure TSestra.UkazatVysetrovny(Sender: TObject);
begin
  Vysetrovny := TVysetrovny.Create(Self);
  Vysetrovny.Show;  // nebo ShowModal pro modální okno
end;


procedure TSestra.ZavolatPacienta(Sender: TObject);
var
  jmenoPacienta: string;
  cisloVysetrovny: string;
  odpoved: Integer;
  pacID: Integer;
  cisloFronty: Integer;
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
  cisloFronty := Pacient.DataSourceCekarna.DataSet.FieldByName('Poradi').AsInteger;


  odpoved := MessageDlg(
    'Opravdu si přejete zavolat pacienta ' + jmenoPacienta + ' do vyšetřovny číslo ' + cisloVysetrovny + '?',
    mtConfirmation,
    [mbYes, mbNo],
    0
  );

  if odpoved = mrYes then
  begin
    // 1) Smazání pacienta z čekárny
    SQLQueryDeleteCekarna.Close;
    SQLQueryDeleteCekarna.SQL.Text := 'DELETE FROM Cekarna WHERE PacientID = :id';
    SQLQueryDeleteCekarna.Params.ParamByName('id').AsInteger := pacID;
    SQLQueryDeleteCekarna.ExecSQL;

    Pacient.SQLTransaction1.CommitRetaining;

    // 2) Obnovení hlavního datasetu, aby pacient zmizel z DBGridu
    Pacient.SQLQueryCekarna.Close;
    Pacient.SQLQueryCekarna.Open;

    Pacient.NastavitDalsiNaRade('Další na řadě: ' + IntToStr(cisloFronty) + ' do vyšetřovny číslo ' + cisloVysetrovny);

    // 3) Hlaska
    ShowMessage('Pacient ' + jmenoPacienta + ' byl vyzván do vyšetřovny ' + cisloVysetrovny + '.');
  end
  else
    ShowMessage('Volání pacienta zrušeno.');
end;


    end.

