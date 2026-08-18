SuperStrict

Framework BRL.StandardIO
Import BRL.Range

Local endpoint:RangeEndpoint = RangeEndpoint.FromEnd(2)

Print endpoint.Resolve(10, 0) ' 8
