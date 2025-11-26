unit Unit3;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, DBGrids;

type

  { TObjednaniPacienti }

  TObjednaniPacienti = class(TForm)
    DBGrid1: TDBGrid;
    DBGrid2: TDBGrid;
  private

  public

  end;

var
  ObjednaniPacienti: TObjednaniPacienti;

implementation

{$R *.lfm}

end.

