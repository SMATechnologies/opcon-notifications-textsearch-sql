/*
Purpose: To search all notifications defined for an OpCon environment using a variety of 
search options specified as declared variables. Comparisons made using these variables are
'like' operations. A single percent sign (%) will match all values. Searches can be narrowed
by providing strings for multiple variables.

Variables used in search include:

@message - string to search the entire message for.  Message includes all recipient addresses as well as the subject and body of the message. This query also searches the TOKEN table for the specified message string and looks to see if that property is being used as part of the message in any notifications. This variable is used most often to find all notifications sent to a particular email address, even if that address is stored as a property in the database.

    "Message" format (broken across multiple lines for readability here) is:

      <MAILTO> email address list </MAILTO>
      <MAILCC> email address list </MAILCC>
      <MAILBCC> email address list </MAILBCC>
      <MAILSUBJ> subject </MAILSUBJ>
      <MAILBODY> message body </MAILBODY>


@trigger can be searched for the triggering event such as 'job failed', 'job cancelled',
'job late to start', etc.

@actionType is generally 'E-Mail', but can be searched for 'OpCon/xps Event', 'Text Message', etc.

@selectString contains the machine, schedule, or job, depending on the type of message group

Created 5/15/2020 by Russ Spencer
Version 1.0

Modifications:
*/
use opconxps 
 
declare @message       varchar(30)  = '%russell.spencer@atos.net%'
declare @trigger       varchar(30)  = '%'
declare @actionType    varchar(30)  = '%'
declare @selectString  varchar(30)  = '%%'
declare @group         varchar(30)  = '%%'
 
select distinct
       "Group",
       "Trigger",
       "Description",
       "Action Type",
       "Active",
       "Message",
       "Select String"
  from (
        SELECT g.groupname                                as "Group",
               t.triggername                              as "Trigger",
               a.actionname                               as "Description",
               case m.ACTIONTYPE
                    when 1 then 'Event Log'
                    when 2 then 'E-Mail'
                    when 3 then 'Net Send'
                    when 4 then 'SNMP'
                    when 5 then 'SPO'
                    when 6 then 'Text Message'
                    when 7 then 'OpCon/xps Event'
               else
                    'Unknown action: ' + cast(m.actiontype as varchar)
               end                                        as "Action Type",
               case m.ACTIONACTIVE
                    when 0 then 'Inactive'
                    when 1 then 'Active'
               else
                    'Unknown'
               end                                        as "Active",
               m.ACTIONMSG                                as "Message",
               case g.grouptype
                    when 'M' then (select machname
                                     from machs
                                    where machid = s.selectid)
                    when 'S' then (select skdname
                                     from sname
                                    where skdid = s.selectid) + ' (ALL JOBS)'
                    when 'J' then (select skdname
                                     from sname
                                    where skdid = s.selectid) + '::' + s.selectstring
               end                                        as "Select String"
          FROM ENSACTIONS  a,
               ENSMESSAGES m,
               ENSGROUPS   g,
               ENSTRIGGERS t,
               ENSSELECTED s
        where m.groupofid    = g.groupofid
          and m.groupofid    = a.groupofid
          and m.groupofid    = s.groupofid
          and a.statuscode   = t.triggercode
          and m.actionid     = a.actionid
          and g.groupexclsel = 0
union
        SELECT g.groupname                                as "Group",
               t.triggername                              as "Trigger",
               a.actionname                               as "Description",
               case m.ACTIONTYPE
                    when 1 then 'Event Log'
                    when 2 then 'E-Mail'
                    when 3 then 'Net Send'
                    when 4 then 'SNMP'
                    when 5 then 'SPO'
                    when 6 then 'Text Message'
                    when 7 then 'OpCon/xps Event'
               else
                    'Unknown action: ' + cast(m.actiontype as varchar)
               end                                        as "Action Type",
               case m.ACTIONACTIVE
                    when 0 then 'Inactive'
                    when 1 then 'Active'
               else
                    'Unknown'
               end                                        as "Active",
               m.ACTIONMSG                                as "Message",
               sn.skdname + '::' + j.jobname              as "Select String"
          FROM ENSACTIONS  a,
               ENSMESSAGES m,
               ENSGROUPS   g,
               ENSTRIGGERS t,
               ENSSELECTED s,
               JMASTER     j,
               SNAME       sn
        where m.groupofid    =  g.groupofid
          and m.groupofid    =  a.groupofid
          and m.groupofid    =  s.groupofid
          and a.statuscode   =  t.triggercode
          and m.actionid     =  a.actionid
          and g.groupexclsel =  1
          and g.grouptype    =  'J'
          and j.skdid        =  s.selectid
          and jobname        <> s.selectstring
          and sn.skdid       =  j.skdid
union
        SELECT distinct
               g.groupname                                as "Group",
               t.triggername                              as "Trigger",
               a.actionname                               as "Description",
               case m.ACTIONTYPE
                    when 1 then 'Event Log'
                    when 2 then 'E-Mail'
                    when 3 then 'Net Send'
                    when 4 then 'SNMP'
                    when 5 then 'SPO'
                    when 6 then 'Text Message'
                    when 7 then 'OpCon/xps Event'
               else
                    'Unknown action: ' + cast(m.actiontype as varchar)
               end                                        as "Action Type",
               case m.ACTIONACTIVE
                    when 0 then 'Inactive'
                    when 1 then 'Active'
               else
                    'Unknown'
               end                                        as "Active",
               m.ACTIONMSG                                as "Message",
               sn.skdname + ' (ALL JOBS)'                 as "Select String"
          FROM ENSACTIONS  a,
               ENSMESSAGES m,
               ENSGROUPS   g,
               ENSTRIGGERS t,
               ENSSELECTED s,
               SNAME       sn
        where m.groupofid    = g.groupofid
          and m.groupofid    = a.groupofid
          and m.groupofid    = s.groupofid
          and a.statuscode   = t.triggercode
          and m.actionid     = a.actionid
          and g.groupexclsel = 1
          and g.grouptype    = 'S'
          and not exists
              (select *
                 from ENSSELECTED s1
                where sn.SKDID       = s1.SELECTID
                  and s.GROUPOFID    = s1.GROUPOFID
                  and s.SELECTSTRING = s1.SELECTSTRING)
union
        SELECT g.groupname                                as "Group",
               t.triggername                              as "Trigger",
               a.actionname                               as "Description",
               case m.ACTIONTYPE
                    when 1 then 'Event Log'
                    when 2 then 'E-Mail'
                    when 3 then 'Net Send'
                    when 4 then 'SNMP'
                    when 5 then 'SPO'
                    when 6 then 'Text Message'
                    when 7 then 'OpCon/xps Event'
               else
                    'Unknown action: ' + cast(m.actiontype as varchar)
               end                                        as "Action Type",
               case m.ACTIONACTIVE
                    when 0 then 'Inactive'
                    when 1 then 'Active'
               else
                    'Unknown'
               end                                        as "Active",
               m.ACTIONMSG                                as "Message",
               mn.machname                                as "Select String"
          FROM ENSACTIONS  a,
               ENSMESSAGES m,
               ENSGROUPS   g left outer join ENSSELECTED s on g.GROUPOFID = s.GROUPOFID,
               ENSTRIGGERS t,
               MACHS       mn
        where m.groupofid    =  g.groupofid
          and m.groupofid    =  a.groupofid
          and a.statuscode   =  t.triggercode
          and m.actionid     =  a.actionid
          and g.groupexclsel =  1
          and g.grouptype    =  'M'
          and (machid        <> s.selectid or s.SELECTID is null)
       ) temp
 where (lower(temp."Message") like @message
 -- search for email info
    /*
    *
    *  Exists condition looks for messages that use global properties to store email addresses
    *  used in notifications.
    *
    */
    or exists
       (select *
          from TOKEN t
         where t.TKNVAL like @message
           and lower(temp."Message") like '%' + t.TKNDESC + '%'))
   and temp."Trigger"       like @trigger              -- search 'job failed', 'job cancelled', etc.
   and temp."Action Type"   like @actionType           -- search for action type
   and temp."Select String" like @selectString
   and temp."Group"         like @group
 order by 1, 2, 7