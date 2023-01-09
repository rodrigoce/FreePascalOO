unit compra_filter;

{$mode ObjFPC}{$H+}

interface

uses
  validatable;

type

  { TCompraFilter }

  TCompraFilter = class(TValidatable)
  private
    FDataFim: TDateTime;
    FDataIni: TDateTime;
    FSituacao: string;
  published
    property DataIni: TDateTime read FDataIni write FDataIni;
    property DataFim: TDateTime read FDataFim write FDataFim;
    property Situacao: string read FSituacao write FSituacao;
  end;

implementation

end.

