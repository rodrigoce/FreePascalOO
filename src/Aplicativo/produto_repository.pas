unit produto_repository;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, repository_base, produto_model;

type
  TProdutoRepository = class(specialize TRepositoryBase<TProdutoModel>)

  end;

implementation

end.

