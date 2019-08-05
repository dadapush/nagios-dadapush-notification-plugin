Nagios DaDaPush Notification Plugin
========================

A Notification Plugin for [Nagios](https://www.nagios.org/) and compatible software (e.g. [Icinga](https://www.icinga.org/)) to enable notifications via [DaDaPush](https://www.dadapush.com/).

## Configuration

1. Copy `nagios-dadapush.sh` to `/usr/local/nagios/libexec`.

2. Create an *[DaDaPush Channel](https://www.dadapush.com/channel/list)* and Copy channel token.

3. Create the command definitions in your Nagios configuration:

```
    define command {
        command_name notify-host-by-dadapush
        command_line /usr/local/nagios/libexec/nagios-dadapush.sh -a "$NOTIFICATIONTYPE$" -b "$HOSTNAME$" -c "$HOSTSTATE$" -d "$HOSTOUTPUT$" -T "DADAPUSH_CHANNEL_TOKEN"
    }

    define command {
        command_name notify-service-by-dadapush
        command_line /usr/local/nagios/libexec/nagios-dadapush.sh -a "$NOTIFICATIONTYPE$" -b "$HOSTNAME$" -e "$SERVICEDESC$" -f "$SERVICESTATE$" -g "$SERVICEOUTPUT$" -T "DADAPUSH_CHANNEL_TOKEN"
    }
```

4. Create the contact definition in your Nagios configuration:

```
    define contact {
        contact_name                            dadapush
        alias                                   dadapush
        service_notification_period             24x7
        host_notification_period                24x7
        service_notification_options            w,u,c,r
        host_notification_options               d,r
        host_notification_commands              notify-host-by-dadapush
        service_notification_commands           notify-service-by-dadapush
    }
```

5. Add the contact to a contact group in your Nagios configuration:

```
    define contactgroup{
        contactgroup_name       network-admins
        alias                   Network Administrators
        members                 email, dadapush
    }
```

read full [Setup Nagios DaDaPush Notification Plugin](https://blog.dadapush.com/2019/08/04/send-nagios-alert-notification-using-dadapush/)

## Other Information

This script has been tested on multiple servers with different versions of curl.

Please fork and contribute if you find any bugs.