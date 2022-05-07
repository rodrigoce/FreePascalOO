unit produto_dal;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, dal_base, produto_entity;

type
  TProdutoDAL = class(specialize TDALBase<TProdutoEntity>)

  end;

implementation

end.

