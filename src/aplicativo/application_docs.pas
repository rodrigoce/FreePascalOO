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

  **** UNITS / CLASSES CORE ***

  TValidatable --> metodos e propriedades para adicionar e obter mensagens de validação
  |- TEntityBase --> classe base para entidades, possui alguns metodos e propriedades de padronização
  |- TDTOs --> classe para transportar dados, como filtros de pesquisa, agregações de Entities, etc.

  TDALBase<T> --> insert, update, select, select, etc.
  |- descentes de DAL

  TValidatorBase<T> --> metodos de validação de fields de Entities ou DTOs

  TBLLBase --> não existe ainda.

  units
  |- mini_orm --> é o mini orm do projeto
  |- prop_to_comp_map --> mapeia propriedades para componentes
  |- mensagem_validacao_form --> Exibe as mensagens de validação de um objeto validatable
  |- filter_composer --> gera a expressão where e insere o parametros em um TSQLQuery
  |- grid_configurator --> configura uma DBGRID

  units basicas para editar por recurso
  entity, validator, filter, filter_validator, dal, bll, cad, man

}

{
UNITS INTERESSANTES

  LazUTF8
}

{
  https://github.com/hiraethbbs/pascal_bcrypt
  https://wiki.freepascal.org/Lazarus_IDE_Tools#Summary_Table_of_IDE_shortcuts
  https://scriptcase.host/pt-br/hospedagem-firebird

  https://stackoverflow.com/questions/9466547/how-to-make-a-combo-box-with-fulltext-search-autocomplete-support
}

end.

