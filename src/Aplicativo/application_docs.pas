unit application_docs;

{$mode ObjFPC}{$H+}

interface

implementation

{
ARQUITETURA

----------
Interface ---> BLL ---> DAL ---> Banco de Dados
Interface <--- BLL <--- DAL <--- Banco de Dados

Interface
  - apenas apresentação de dados
  - troca dados com BLL por DTOs para casos complexos
  - trocar de dados com BLL com entities puras para casos simples

Service
  - cria novas instancias (com inicializações de campos, listas, ...)
  - chama ou faz validações com validatos
  - chama insert, update...

DAL ->
  - selects
  - inserts
  - updates
  - deletes
  - logs


  TValidatable --> class com métodos para validação de fields (properties)
  |- TEntityBase --> class from properties padrão
  |- TDTOs --> classes com outras Entities como properties ou campos de filtros para telas de pesquisa

  TDALBase --> insert, update, select, select, etc.
  |- descentes de DAL

  TValidatorBase<T> --> metodos de validação de fields de Entities ou DTOs

  TBLLBase --> não existe ainda.

  units
  |- mini_orm --> é o mini orm do projeto



}

{
UNITS INTERESSANTES

  LazUTF8
}

{
  https://github.com/hiraethbbs/pascal_bcrypt

}

end.

