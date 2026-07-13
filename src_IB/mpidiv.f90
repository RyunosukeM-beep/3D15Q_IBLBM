module mpidivide
    use kinds
    use LBMparams
    implicit none
    contains
    
    subroutine mpidiv(rank,endN,istart,iend,nprank)
        implicit none
        integer endN,rank
        integer :: base, remainder
        integer :: istart,iend
        integer :: nprank

        base = endN / nprank
        remainder = mod(endN,nprank)

        if (rank < remainder) then
            istart = rank * (base + 1) + 1
            iend   = istart + base
        else
            istart = remainder * (base + 1) + (rank - remainder) * base + 1
            iend   = istart + base - 1
        end if

        return
    end subroutine mpidiv

        
end module mpidivide