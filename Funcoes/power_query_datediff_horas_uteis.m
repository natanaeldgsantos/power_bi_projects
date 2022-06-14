/*

* title:     Datetime Diff considerando lista de feriados e expediente
* shared by: Natanael Domingos
* version: 01
* description:

   A seguinte função em linguagem M para Power Query tem como objetivo extrair a quantidade de horas úteis
   entre uma data e outra (datetime) considerando:
   . Horário de Inicio do Expediente
   . Horário de Término do Expediente
   . Dias úteis na semana
   . Lista de feriados passada como parâmetro

*/


(InicioExpediente, FimExpediente, Abertura, Fechamento, ListaFeriados) =>

let 

DiaDaAbertura   = Number.From(DateTime.Date(Abertura)),
DiaDoFechamento = Number.From(DateTime.Date(Fechamento)),

HorarioDaAbertura   = Number.From(DateTime.Time(Abertura)),
HorarioDoFechamento = Number.From(DateTime.Time(Fechamento)),

// Lista dos dias sem Sábados e Domingos
ListaDeDatas = List.Select({DiaDaAbertura..DiaDoFechamento}, each Number.Mod(_,7)>1),

// Lista dos dias sem Sábados, Domingos e Feriádos.
// Retorna apenas os números diferentes não existentes na tabela feriado, ou seja apenas não feriados.
ListaDiasUteis = List.Difference(ListaDeDatas,ListaFeriados),


SomaHorasUteis = 
        // Verifica se o dia da abertua é igual ao dia do fechamento
        if DiaDaAbertura = DiaDoFechamento then
                if DiaDaAbertura = List.First(ListaDiasUteis) then
                        // Verifica se o dia de abertura não é feriado. (DtAbertura = DtFechamento)
                        List.Median({InicioExpediente,FimExpediente,HorarioDoFechamento}) - List.Median({InicioExpediente,FimExpediente,HorarioDaAbertura})
                else 0
        else (
                if DiaDaAbertura = List.First(ListaDiasUteis) then
                        // Verifica se o dia da abertura é dia útil (DtAbertura <> DtFechamento)
                        FimExpediente - List.Median({InicioExpediente,FimExpediente,HorarioDaAbertura})
                else 0
        )
        +
        (       
                if DiaDoFechamento = List.Last(ListaDiasUteis) then 
                        // Verifica se o dia de fechamento é dia útil (DtAbertura <> DtFechamento)
                        List.Median({InicioExpediente,FimExpediente,HorarioDoFechamento}) - InicioExpediente
                else 0
        )
        +
        (
                //Soma to total de horas úteis excluindo (DiaAbertura, DiaFechamento, Feriados, Sábados e Domingos)
                List.Count(List.Difference(ListaDiasUteis,{DiaDaAbertura,DiaDoFechamento}))*(FimExpediente - InicioExpediente)
        )

in 

SomaHorasUteis