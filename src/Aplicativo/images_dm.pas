unit images_dm;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Controls;

type

  { TImagesDM }

  TImagesDM = class(TDataModule)
    ImageListMenu: TImageList;
  private

  public

  end;

var
  ImagesDM: TImagesDM;

implementation

{$R *.lfm}

end.

