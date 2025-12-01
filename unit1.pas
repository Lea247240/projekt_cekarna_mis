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
    Image1: TImage;
    Image2: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    LabelTime: TLabel;
    LabelDalsi: TLabel;
    LabelRada: TLabel;
    Panel4: TPanel;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    PotvrdHeslo: TButton;
    EditHeslo: TEdit;
    SQLQueryCekarnaInsert: TSQLQuery;
    SQLQueryHeslo: TSQLQuery;
    Timer1: TTimer;
    ZadejHesloButton: TButton;
    DataSourceCekarna: TDataSource;
    DataSourceVykon: TDataSource;
    DataSourcePacient: TDataSource;
    SQLite3Connection1: TSQLite3Connection;
    SQLQueryCekarna: TSQLQuery;
    SQLQueryVykon: TSQLQuery;
    SQLQueryPacient: TSQLQuery;
    SQLTransaction1: TSQLTransaction;
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure OtevriSestru(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Panel3Resize(Sender: TObject);
    procedure Panel5Click(Sender: TObject);
    procedure PotvrdHesloClick(Sender: TObject);
    procedure hodiny(Sender: TObject);
    procedure ZadejHesloButtonClick(Sender: TObject);

  private

  public
    procedure NastavitDalsiNaRade(const s: string);
    procedure ZobrazOkno;

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

  //Sestra.Show;
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

  // Ihned zobrazíme aktuální čas
  LabelTime.Caption := FormatDateTime('hh:nn:ss', Now);

  // Spustíme timer
  Timer1.Enabled := True;


end;


procedure TPacient.Panel3Resize(Sender: TObject);
begin
  Panel4.Left := (Panel3.Width - Panel4.Width) div 2;
  Panel4.Top := (Panel3.Height - Panel4.Height) div 2;
end;

procedure TPacient.Panel5Click(Sender: TObject);
begin

end;


procedure TPacient.ZobrazOkno;
begin
  if WindowState = wsMinimized then
    WindowState := wsNormal;

  Show;
  BringToFront;
  SetFocus;
end;

procedure TPacient.OtevriSestru(Sender: TObject);
begin
   Sestra.Show;
end;

procedure TPacient.FormShow(Sender: TObject);
begin
    Panel1.Align := alTop;
end;



procedure TPacient.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

  if (ssCtrl in Shift) and (Key = Ord('S')) then
  begin
    Sestra.ZobrazOkno;
    Key := 0;
  end;
end;

procedure TPacient.FormResize(Sender: TObject);
begin

   Panel2.Top := Panel1.Top + Panel1.Height;
   Panel3.Top := Panel2.Top + Panel2.Height;



  ZadejHesloButton.Left := (ClientWidth div 2) - (ZadejHesloButton.Width div 2) - 350; // doprava
  ZadejHesloButton.Top := Panel3.Top + Panel3.Height + 60;


  Label3.Left := (ClientWidth div 2) - (Label3.Width div 2) - 20; // doprava
  Label3.Top := Panel3.Top + Panel3.Height + 15;


  EditHeslo.Left := (ClientWidth div 2) - (EditHeslo .Width div 2) - 10; // doprava
  EditHeslo.Top := Panel3.Top + Panel3.Height + 70;



  PotvrdHeslo.Left := (ClientWidth div 2) - (PotvrdHeslo.Width div 2) + 300; // doprava
  PotvrdHeslo.Top := Panel3.Top + Panel3.Height + 60;


  LabelRada.Left := (ClientWidth div 2) - (LabelRada.Width div 2); // doprava
  LabelRada.Top := EditHeslo.Top + EditHeslo.Height + 30;

  Image1.Left := (ClientWidth div 2) - (Image1.Width div 2);
  Image1.Top := LabelRada.Top + LabelRada.Height + 40;
  Image2.Left := (ClientWidth div 2) - (Image2.Width div 2);
  Image2.Top := LabelRada.Top + LabelRada.Height + 40;


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
    LabelRada.Caption := 'Zadejte heslo!';
    Image1.Visible := False;
    Image2.Visible := True;
    Exit;
  end;


  // Ověření hesla
  SQLQueryHeslo.Close;
  SQLQueryHeslo.ParamByName('h').AsString := heslo;
  SQLQueryHeslo.Open;

  // Pokud zadá špatně
  if SQLQueryHeslo.IsEmpty then
  begin
    LabelRada.Caption := 'Nesprávné heslo!';
    Image1.Visible := False;
    Image2.Visible := True;
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

  LabelRada.Caption :=  'Vaše pořadové číslo je: ' + IntToStr(dalsiPoradi);
  EditHeslo.Text := '';
  Image2.Visible := False;
  Image1.Visible := True;


end;

procedure TPacient.hodiny(Sender: TObject);
begin
  LabelTime.Caption := FormatDateTime('hh:nn:ss', Now);
end;


// Při zmáčknutí tlačítka Zadej heslo
procedure TPacient.ZadejHesloButtonClick(Sender: TObject);
begin
  EditHeslo.Visible := True;
  PotvrdHeslo.Visible := True;
  Label3.Visible := True;
  EditHeslo.SetFocus;
  LabelRada.Caption := ''; // vyčistí případnou starou zprávu
end;


procedure TPacient.NastavitDalsiNaRade(const s: string);
begin
  LabelDalsi.Caption := s;
end;


end.

