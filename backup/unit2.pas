unit Unit2;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, SQLDB, DB, Forms, Controls, Graphics, Dialogs, DBGrids;

type

  { TSestra }

  TSestra = class(TForm)
    DataSourceVykon: TDataSource;
    DBGrid2: TDBGrid;
    DBGrid3: TDBGrid;
    SQLQueryVykon: TSQLQuery;
    procedure FormCreate(Sender: TObject);

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
  SQLQueryVykon.Open;
end;

end.

