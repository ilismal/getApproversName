#Leemos el fichero XML con la lista de aprobadores y backups
[xml]$aprobadores = Get-Content .\approvers.xml
#Recorremos los subtipos <owners><type><subtype>
$aprobadores.owners.type.subtype | ForEach-Object {
    #Objeto para almacenar los resultados
    $resultado = New-Object -TypeName PSObject
    Try{
        $aprobador = Get-ADUser -Identity $_.owner_id -Properties *
    }
    #Controlamos el error, asumiendo que se debe a que el usuario no existe en el AD
    #TODO: Controlar el error *específico*
    Catch{
        $nombre = "NE"
        $aprobador | Add-Member -MemberType NoteProperty -Name name $nombre -Force
        $aprobador | Add-Member -MemberType NoteProperty -Name enabled -Value $false -Force
    }
    #Repetimos el ejercicio para los backups (si están definidos)
    if ($_.backup_id -ne "none"){
        Try{
            $backup = Get-ADUser -Identity $_.backup_id -Properties *
        }
        Catch{
        $nombre = "NE"
        $backup | Add-Member -MemberType NoteProperty -Name name $nombre -Force
        $backup | Add-Member -MemberType NoteProperty -Name enabled -Value $false -Force
        }
    }
    else{
        $backup | Add-Member -MemberType NoteProperty -Name enabled -Value $false -Force
        $backup | Add-Member -MemberType NoteProperty -Name name -Value "none" -Force
    }
    $resultado | Add-Member -MemberType NoteProperty -Name aplicacion -Value $_.name
    $resultado | Add-Member -MemberType NoteProperty -Name aprobador -Value $aprobador.name
    if ($aprobador.enabled) {
        $resultado | Add-Member -MemberType NoteProperty -Name habilitado -Value "SI"
    }
    else{
        $resultado | Add-Member -MemberType NoteProperty -Name habilitado -Value "NO"
    }
    $resultado | Add-Member -MemberType NoteProperty -Name backup -Value $backup.name
    if ($backup.enabled) {
        $resultado | Add-Member -MemberType NoteProperty -Name habilitadoB -Value "SI"
    }
    else{
        $resultado | Add-Member -MemberType NoteProperty -Name habilitadoB -Value "NO"
    }
    #Por último exportamos a CSV
    $resultado | Select-Object aplicacion,aprobador,habilitado,backup,habilitadoB | Export-Csv .\approvers.csv -Append
}
