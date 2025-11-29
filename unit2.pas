unit Unit2;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, SQLDB, DB, Forms, Controls, Graphics, Dialogs, DBGrids,
  StdCtrls, DBCtrls, Menus, ActnList, ExtCtrls;

type

  { TSestra }

  TSestra = class(TForm)
    Button1: TButton;
    ButtonPacient: TButton;
    DataSourceVysetrovna: TDataSource;
    DataSourceVykon2: TDataSource;
    DBGrid2: TDBGrid;
    DBGrid3: TDBGrid;
    DBLookupComboBox1: TDBLookupComboBox;
    Label1: TLabel;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem10: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem12: TMenuItem;
    MenuItem13: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    Panel1: TPanel;
    PopupMenu1: TPopupMenu;
    SQLQueryDeleteCekarna: TSQLQuery;
    SQLQueryVysetrovna: TSQLQuery;
    SQLQueryVykon2: TSQLQuery;
    procedure ButtonPacientClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormResize(Sender: TObject);
    procedure UkazatAutory(Sender: TObject);
    procedure UkazatNapovedu(Sender: TObject);
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
    uses Unit1, Unit3, Unit4, LCLIntf, Unit5;
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

procedure TSestra.ButtonPacientClick(Sender: TObject);
begin
   Hide;
    Pacient.ZobrazOkno;
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


if (Shift = [ssCtrl]) and (Key = Ord('Z')) then
begin
    ZavolatPacienta(Self);
    end;


end;

procedure TSestra.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
   
if Button = mbRight then
    PopupMenu1.Popup(Mouse.CursorPos.X, Mouse.CursorPos.Y)

end;

procedure TSestra.FormResize(Sender: TObject);
const
  mezera = 100;
var
  celkovaSirka: Integer;
begin
  celkovaSirka := DBGrid3.Width + mezera + DBGrid2.Width;

  DBGrid3.Left := (Panel1.ClientWidth div 2) - (celkovaSirka div 2);

  DBGrid2.Left := DBGrid3.Left + DBGrid3.Width + mezera;

  DBGrid3.Top := Panel1.ClientHeight - DBGrid3.Height - 20;
  DBGrid2.Top := DBGrid3.Top;


  Button1.Left := (ClientWidth div 2) - (Button1.Width div 2);
  Button1.Top := Panel1.Top + Panel1.Height + 15;

  Label1.Left := (ClientWidth div 2) - (Label1.Width div 2);
  Label1.Top := Button1.Top + Button1.Height + 40;


  DBLookupComboBox1.Left := (ClientWidth div 2) - (DBLookupComboBox1.Width div 2);
  DBLookupComboBox1.Top := Label1.Top + Label1.Height + 20;
end;

procedure TSestra.UkazatAutory(Sender: TObject);
begin
  Autori.ShowModal;
end;



procedure TSestra.UkazatNapovedu(Sender: TObject);
begin
  OpenDocument('napoveda.txt');
end;


procedure TSestra.NovyDen(Sender: TObject);
var
  odpoved: Integer;
begin
     odpoved := MessageDlg(
    'Opravdu si přejete smazat záznamy a zahájit nový den?',
    mtConfirmation,
    [mbYes, mbNo],
    0
  );

  if odpoved = mrYes then
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

  Pacient.LabelDalsi.Caption := '';
  Pacient.LabelRada.Caption := '';

  Pacient.Image1.Visible := False;
  Pacient.Image2.Visible := False;

  Pacient.Label3.Visible := False;
  Pacient.EditHeslo.Visible := False;


  end;

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

    Pacient.NastavitDalsiNaRade('Další na řadě: ' + IntToStr(cisloFronty) + LineEnding + 'do vyšetřovny číslo ' + cisloVysetrovny);

    // 3) Hlaska
    ShowMessage('Pacient ' + jmenoPacienta + ' byl vyzván do vyšetřovny ' + cisloVysetrovny + '.');
  end
  else
    ShowMessage('Volání pacienta zrušeno.');
end;

    end.

