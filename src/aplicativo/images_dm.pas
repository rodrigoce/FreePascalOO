unit images_dm;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, Controls;

type

  { TImagesDM }

  TImagesDM = class(TDataModule)
    ImageListBtn: TImageList;
    ImageListMenu: TImageList;
    procedure DataModuleCreate(Sender: TObject);
  private

  public

  end;

var
  ImagesDM: TImagesDM;

implementation

{$R *.lfm}

{ TImagesDM }

procedure TImagesDM.DataModuleCreate(Sender: TObject);
begin

end;

end.

