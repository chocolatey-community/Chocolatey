InModuleScope Chocolatey {
    Describe Get-PrivateFunction {
        Mock Get-RemoteFile -MockWith {}
        Mock Get-RemoteString -MockWith {}
        Mock Copy-Item -MockWith {}
        Mock Expand-Archive -MockWith {}
        Mock New-Item -MockWith {}

        Context 'Default' {
            BeforeEach {
                $return = Get-PrivateFunction -PrivateData 'string'
            }

            It 'Returns a single object' {
                ($return | Measure-Object).Count | Should -Be 1
            }

            It 'Returns a string based on the parameter PrivateData' {
                $return | Should -Be 'string'
            }
        }
    }
}