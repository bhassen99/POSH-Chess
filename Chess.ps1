#####################################################################################
#Requires -Version 5.0
#####################################################################################
#                                                      _:_
#     ========================                        '-.-'
#    | PowerShell Chess V 0.2 |              ()      __.'.__
#     ========================            .-:--:-.  |_______|
#                                  ()      \____/    \=====/
#                                  /\      {====}     )___(
#                       (\=,      //\\      )__(     /_____\
#       __    |'-'-'|  //  .\    (    )    /____\     |   |
#      /  \   |_____| (( \_  \    )__(      |  |      |   |
#      \__/    |===|   ))  `\_)  /____\     |  |      |   |
#     /____\   |   |  (/     \    |  |      |  |      |   |
#      |  |    |   |   | _.-'|    |  |      |  |      |   |
#      |__|    )___(    )___(    /____\    /____\    /_____\
#     (====)  (=====)  (=====)  (======)  (======)  (=======)
#     }===={  }====={  }====={  }======{  }======{  }======={
#    (______)(_______)(_______)(________)(________)(_________)
#################################################################


<#
.SYNOPSIS
    I couldn't find a chess game that was written in powershell, so I made one.

.NOTES
    Name: Chess.ps1
    Version: 0.1
    Author: Chojiku
    Date: 03-12-2016

.CHANGELOG
        0.1 - Chojiku - 03-12-2016 - Initial Script
        0.2 - Chojiku - 03-14-2016 - Added player turns with prompts.

.EXAMPLE
        .\Chess.ps1 

.PLANS_FOR_FUTURE
    - Fix and optimize movement
    - Resize window and center board
    - Player turns tied in with piece color
    - Game save/load function
    - Main menu
    - Player AI
    - Play over LAN
    - Mouse support through gridview or cursorpos
    - Make pretty
	- Notifications
	- Way to win
	- Check/Checkmate
    - Fix display when ran from console
	
#>

#Creates the game board [MultiDimensional Array], may increase size in future to make conversion easier.
[Object]$Script:board = New-Object 'object[,]' 8,8

#Creates a turn status. Plans to use in future versions.
[Boolean]$Script:Player1Turn = $true

####################################################
#region: Functions
###########################

#Clears the board of pieces
Function Clear-Board { 
    $board[0,0]=$board[0,7]=$board[0,1]=$board[0,6]=$board[0,2]=$board[0,5]=$board[0,3]=$board[0,4]=$null
    $board[1,0]=$board[1,1]=$board[1,2]=$board[1,3]=$board[1,4]=$board[1,5]=$board[1,6]=$board[1,7]=$null
    $board[2,0]=$board[2,1]=$board[2,2]=$board[2,3]=$board[2,4]=$board[2,5]=$board[2,6]=$board[2,7]=$null
    $board[3,0]=$board[3,1]=$board[3,2]=$board[3,3]=$board[3,4]=$board[3,5]=$board[3,6]=$board[3,7]=$null
    $board[4,0]=$board[4,1]=$board[4,2]=$board[4,3]=$board[4,4]=$board[4,5]=$board[4,6]=$board[4,7]=$null
    $board[5,0]=$board[5,1]=$board[5,2]=$board[5,3]=$board[5,4]=$board[5,5]=$board[5,6]=$board[5,7]=$null
    $board[6,0]=$board[6,1]=$board[6,2]=$board[6,3]=$board[6,4]=$board[6,5]=$board[6,6]=$board[6,7]=$null
    $board[7,0]=$board[7,7]=$board[7,1]=$board[7,6]=$board[7,2]=$board[7,5]=$board[7,3]=$board[7,4]=$null
}

#Displays the gameboard
Function Draw-Board {
	#Get arrays of all piece that are still alive
    [Array] $CurrentWhite = $WhitePieces | Where {$_.Alive -eq $true}
    [Array] $CurrentBlack = $BlackPieces | Where {$_.Alive -eq $true}
    
	#Place all the white pieces
    ForEach ($pc in $CurrentWhite) {
        $board[($pc.CurrentRow),($pc.CurrentColumn)] = $pc
    }
    #Place all the black pieces
    ForEach ($pc in $CurrentBlack) {
        $board[($pc.CurrentRow),($pc.CurrentColumn)] = $pc
    }

	#Check for spaces without a piece in them, then fill it with the empty placeholder.
    for($r=0; $r -le 7; $r++) {
        for($c=0; $c -le 7; $c++) {
            If ($board[$r,$c] -eq $null) {$board[$r,$c] = $Empty}
        }
    }

    #Draw the board
    Write-Host '     1    2    3   4    5    6   7    8'
    Write-Host '   -------------------------------------- '
    Write-Host ' A |'$board[0,0].Icon'|'$board[0,1].Icon'|'$board[0,2].Icon'|'$board[0,3].Icon'|'$board[0,4].Icon'|'$board[0,5].Icon'|'$board[0,6].Icon'|'$board[0,7].Icon'|'
    Write-Host '   -------------------------------------- '
    Write-Host ' B |'$board[1,0].Icon'|'$board[1,1].Icon'|'$board[1,2].Icon'|'$board[1,3].Icon'|'$board[1,4].Icon'|'$board[1,5].Icon'|'$board[1,6].Icon'|'$board[1,7].Icon'|'
    Write-Host '   -------------------------------------- '
    Write-Host ' C |'$board[2,0].Icon'|'$board[2,1].Icon'|'$board[2,2].Icon'|'$board[2,3].Icon'|'$board[2,4].Icon'|'$board[2,5].Icon'|'$board[2,6].Icon'|'$board[2,7].Icon'|'
    Write-Host '   -------------------------------------- '
    Write-Host ' D |'$board[3,0].Icon'|'$board[3,1].Icon'|'$board[3,2].Icon'|'$board[3,3].Icon'|'$board[3,4].Icon'|'$board[3,5].Icon'|'$board[3,6].Icon'|'$board[3,7].Icon'|'
    Write-Host '   -------------------------------------- '
    Write-Host ' E |'$board[4,0].Icon'|'$board[4,1].Icon'|'$board[4,2].Icon'|'$board[4,3].Icon'|'$board[4,4].Icon'|'$board[4,5].Icon'|'$board[4,6].Icon'|'$board[4,7].Icon'|'
    Write-Host '   -------------------------------------- '
    Write-Host ' F |'$board[5,0].Icon'|'$board[5,1].Icon'|'$board[5,2].Icon'|'$board[5,3].Icon'|'$board[5,4].Icon'|'$board[5,5].Icon'|'$board[5,6].Icon'|'$board[5,7].Icon'|'
    Write-Host '   -------------------------------------- '
    Write-Host ' G |'$board[6,0].Icon'|'$board[6,1].Icon'|'$board[6,2].Icon'|'$board[6,3].Icon'|'$board[6,4].Icon'|'$board[6,5].Icon'|'$board[6,6].Icon'|'$board[6,7].Icon'|'
    Write-Host '   -------------------------------------- '
    Write-Host ' H |'$board[7,0].Icon'|'$board[7,1].Icon'|'$board[7,2].Icon'|'$board[7,3].Icon'|'$board[7,4].Icon'|'$board[7,5].Icon'|'$board[7,6].Icon'|'$board[7,7].Icon'|'
    Write-Host '   -------------------------------------- '
    Write-Host '     1    2    3   4    5    6   7    8'

    
    #Ask the player what they would like to move
    If($Player1Turn) {
	    $Src = Read-Host "Player1 - What piece do you want to move? "
	    $Dst = Read-Host "Player1 - Where would you like to move it? "
	    Move-Piece $Src $Dst
    } Else {
	    $Src = Read-Host "Player2 - What piece do you want to move? "
	    $Dst = Read-Host "Player2 - Where would you like to move it? "
	    Move-Piece $Src $Dst
    }
}

#Used to move pieces on the board
Function Move-Piece {
    Param ([String]$source,[String]$dest)
    #Param [String]$source='h3';[String]$dest='e6'

    [Boolean]$Attack = $false #Taking piece?
    [Boolean]$MoveSuccess = $false #Is this a legal move

    #Clear the console
    Clear-Host

    Try {
        #Ensure that the coordinates are on the board
        [ValidateRange(0,8)][Int]$CurrentRow = Get-Row $source[0]
        [ValidateRange(0,8)][Int]$CurrentColumn = $source[1].ToString() - 1
        [ValidateRange(0,8)][Int]$DesiredRow = Get-Row $dest[0]
        [ValidateRange(0,8)][Int]$DesiredColumn = $dest[1].ToString() - 1

        #Get the piece that is in the source space
        $pc = $board[$CurrentRow,$CurrentColumn]

        #Is this the first time that the piece is moving?
        [Boolean]$FirstMvPC = $pc.CurrentPosition -eq $pc.StartingPosition 

        #Is the destination space where it started? -Not sure why I am checking this...
        [Boolean]$FirstMvDst = $board[$DesiredRow,$DesiredColumn].CurrentPosition -eq $board[$DesiredRow,$DesiredColumn].StartingPosition
    
    } Catch {
        #You messed up, try again
        Write-Host "[Error]`t Illegal Move!! Try again.`n"
        Draw-Board
        Break
    }

    #Check if the user is moving a empty piece
    If ($board[$CurrentRow,$CurrentColumn] -eq $Empty) {
        Write-Host "[Error]`t There is nothing to move. Try Again.`n"
        Draw-Board
        Break
    }

    If (($CurrentRow -eq $DesiredRow) -and ($CurrentColumn -eq $DesiredColumn)) {
         Write-Host "[Error]`t That wouldn't move anything. Try again.`n"
         Draw-Board
         Break
    }

    If ($board[$DesiredRow,$DesiredColumn] -ne $Empty) {
        If ($pc.Color -eq $board[$DesiredRow,$DesiredColumn].Color) {
            If ((($pc.GetType().Name -eq "King") -and ($board[$DesiredRow,$DesiredColumn].GetType().Name -eq "Rook")) -or (($pc.GetType().Name -eq "Rook") -and ($board[$DesiredRow,$DesiredColumn].GetType().Name -eq "King"))) {
                If (($FirstMvPC) -and ($FirstMvDst)) {
                    <#$board[$DesiredRow,$DesiredColumn].CurrentRow = $pc.CurrentRow
                    $board[$DesiredRow,$DesiredColumn].CurrentColumn = $pc.CurrentColumn
                    $pc.CurrentRow = $DesiredRow
                    $pc.CurrentColumn = $DesiredColumn #>
                    $MoveSuccess = $true
                } Else {
                    Write-Host "[Error]`t Castling is not allowed with moved pieces.`n"
                }

            } Else {
                Write-Host "[Error]`t Two pieces cannot share a square.`n"
            }

        } Else {
            [Boolean]$Attack = $true
        }
    }

    If ($CurrentRow -gt $DesiredRow) {
        [Int]$MoveY = $CurrentRow - $DesiredRow
    } Else {
        [Int]$MoveY = $DesiredRow - $CurrentRow
    } 
    
    If ($CurrentColumn -gt $DesiredColumn) {
        [Int]$MoveX = $CurrentColumn - $DesiredColumn
    } Else {
        [Int]$MoveX = $DesiredColumn - $CurrentColumn
    } 

    switch ($pc.GetType().Name) {
        'Pawn' {
            If (($MoveX -le 1) -and ($MoveY -le 2)) {
                If ((($MoveX -eq 1) -eq $Attack) -or (($MoveX -eq 0) -eq (!($Attack)))) {
                    switch ($MoveY) {
                        '1' {$MoveSuccess = $true}

                        '2' {
                            If ($FirstMvPC) {
                                $MoveSuccess =$true
                            } Else { 
                                Write-Host "[Error]`t Illegal Move!! Try again.`n"
                                Break
                            }
                        }
                
                        default {
                            Write-Host "[Error]`t That wouldn't move anything. Try again.`n"
                            Break
                        }
                    }
                } Else {
                    Write-Host "[Error]`t Illegal Move!! Try again.`n"
                    Break
                }
            } Else {
                    Write-Host "[Error]`t Illegal Move!! Try again.`n"
                    Break
            }
        }

        'Rook' {
            If ((($MoveX -eq 0) -and ($MoveY -gt 0)) -or (($MoveX -gt 0) -and ($MoveY -eq 0))) {
                [Byte]$i=0
                If ($MoveY -gt 0) {
                    If ($DesiredRow -gt $CurrentRow) {
                        for($r=$DesiredRow; $r -gt $CurrentRow; $r--) {
                            If ($board[$r,$CurrentColumn] -eq $Empty) {
                                $i++
                            } Else {
                                Write-Host "[Error]`t Illegal Move!! Try again.`n"
                                Break
                            }
                        }
                    } Else {
                        for($r=$DesiredRow; $r -lt $CurrentRow; $r++) {
                            If ($board[$r,$CurrentColumn] -eq $Empty) {
                                $i++
                            } Else {
                                Write-Host "[Error]`t Illegal Move!! Try again.`n"
                                Break
                            }
                        }
                    }
                    If ($MoveY -eq $i) {$MoveSuccess =$true} 
                } Else {
                    If ($DesiredColumn -gt $CurrentColumn) {
                        for($c=$DesiredColumn; $c -gt $CurrentColumn; $c--) {
                            If ($board[$CurrentRow,$c] -eq $Empty) {
                                $i++
                            } Else {
                                Write-Host "[Error]`t Illegal Move!! Try again.`n"
                                Break
                            }
                        }
                    } Else {
                        for($c=$DesiredColumn; $c -lt $CurrentColumn; $c++) {
                            If ($board[$CurrentRow,$c] -eq $Empty) {
                                $i++
                            } Else {
                                Write-Host "[Error]`t Illegal Move!! Try again.`n"
                                Break
                            }
                        }
                    }
                    If ($MoveX -eq $i) {$MoveSuccess =$true} 
                }
                
                                
            } Else {
                Write-Host "[Error]`t Illegal Move!! Try again.`n"
                Break
            }
        }

        'Knight' {
            If ((($MoveX -eq 1) -and ($MoveY -eq 2)) -or (($MoveX -eq 2) -and ($MoveY -eq 1))) {
                $MoveSuccess =$true
            } Else {
                Write-Host "[Error]`t Illegal Move!! Try again.`n"
                Break
            }
        }

        'Bishop' {
            If ($MoveX -eq $MoveY) {
                [Byte]$i=0
                $c=$DesiredColumn
                If ($DesiredRow -gt $CurrentRow) {
                        If ($DesiredColumn -gt $CurrentColumn) {
                            for($r=$DesiredRow; $r -gt $CurrentRow; $r--) {
                                If ($board[$r,$c] -eq $Empty) {
                                    $c--
                                    $i++
                                } Else {
                                    If ($Attack) {
                                        $c--
                                    } Else {
                                        Write-Host "[Error]`t Illegal Move!! Try again.`n"
                                        Break
                                    }                                    
                                }
                            }
                        } Else {
                            for($r=$DesiredRow; $r -gt $CurrentRow; $r--) {
                                If ($board[$r,$c] -eq $Empty) {
                                    $c++
                                    $i++
                                } Else {
                                    If ($Attack) {
                                        $c--
                                    } Else {
                                        Write-Host "[Error]`t Illegal Move!! Try again.`n"
                                        Break
                                    }                                    
                                }
                            }
                        }
                } Else {
                    If($DesiredColumn -gt $CurrentColumn) {
                        for($r=$DesiredRow; $r -lt $CurrentRow; $r++) {
                            If ($board[$r,$c] -eq $Empty) {
                                $c--
                                $i++
                            } Else {
                                If ($Attack) {
                                    $c--
                                } Else {
                                    Write-Host "[Error]`t Illegal Move!! Try again.`n"
                                    Break
                                } 
                            }
                        }
                    } Else {
                        for($r=$DesiredRow; $r -lt $CurrentRow; $r++) {
                            If ($board[$r,$c] -eq $Empty) {
                                $c++
                                $i++
                            } Else {
                                If ($Attack) {
                                    $c++
                                } Else {
                                    Write-Host "[Error]`t Illegal Move!! Try again.`n"
                                    Break
                                } 
                            }
                        }
                    }
                }
                If ($Attack) {$i++}
                If ($MoveX -eq $i) {$MoveSuccess =$true}
                
            } Else {
                Write-Host "[Error]`t Illegal Move!! Try again.`n"
                Break
            }
        }

        'King' {
            If (($MoveX -eq 1) -and ($MoveY -eq 1)) {
                $MoveSuccess = $true
            } Else {
                Write-Host "[Error]`t Illegal Move!! Try again.`n"
                Break
            }
        }

        'Queen' {
            If ((($MoveX -eq 0) -and ($MoveY -gt 0)) -or (($MoveX -gt 0) -and ($MoveY -eq 0))) {
                [Byte]$i=0
                If ($MoveY -gt 0) {
                    If ($DesiredRow -gt $CurrentRow) {
                        for($r=$DesiredRow; $r -gt $CurrentRow; $r--) {
                            If ($board[$r,$CurrentColumn] -eq $Empty) {
                                $i++
                            } Else {
                                Write-Host "[Error]`t Illegal Move!! Try again.`n"
                                Break
                            }
                        }
                    } Else {
                        for($r=$DesiredRow; $r -lt $CurrentRow; $r++) {
                            If ($board[$r,$CurrentColumn] -eq $Empty) {
                                $i++
                            } Else {
                                Write-Host "[Error]`t Illegal Move!! Try again.`n"
                                Break
                            }
                        }
                    }
                    If ($MoveY -eq $i) {$MoveSuccess =$true} 
                } Else {
                    If ($DesiredColumn -gt $CurrentColumn) {
                        for($c=$DesiredColumn; $c -gt $CurrentColumn; $c--) {
                            If ($board[$CurrentRow,$c] -eq $Empty) {
                                $i++
                            } Else {
                                Write-Host "[Error]`t Illegal Move!! Try again.`n"
                                Break
                            }
                        }
                    } Else {
                        for($c=$DesiredColumn; $c -lt $CurrentColumn; $c++) {
                            If ($board[$CurrentRow,$c] -eq $Empty) {
                                $i++
                            } Else {
                                Write-Host "[Error]`t Illegal Move!! Try again.`n"
                                Break
                            }
                        }
                    }
                    If ($MoveX -eq $i) {$MoveSuccess =$true} 
                }
                
                                
            } ElseIf ($MoveX -eq $MoveY) {
                [Byte]$i=0
                $c=$DesiredColumn
                If ($DesiredRow -gt $CurrentRow) {
                        If ($DesiredColumn -gt $CurrentColumn) {
                            for($r=$DesiredRow; $r -gt $CurrentRow; $r--) {
                                If ($board[$r,$c] -eq $Empty) {
                                    $c--
                                    $i++
                                } Else {
                                    If ($Attack) {
                                        $c--
                                    } Else {
                                        Write-Host "[Error]`t Illegal Move!! Try again.`n"
                                        Break
                                    }                                    
                                }
                            }
                        } Else {
                            for($r=$DesiredRow; $r -gt $CurrentRow; $r--) {
                                If ($board[$r,$c] -eq $Empty) {
                                    $c++
                                    $i++
                                } Else {
                                    If ($Attack) {
                                        $c--
                                    } Else {
                                        Write-Host "[Error]`t Illegal Move!! Try again.`n"
                                        Break
                                    }                                    
                                }
                            }
                        }
                } Else {
                    If($DesiredColumn -gt $CurrentColumn) {
                        for($r=$DesiredRow; $r -lt $CurrentRow; $r++) {
                            If ($board[$r,$c] -eq $Empty) {
                                $c--
                                $i++
                            } Else {
                                If ($Attack) {
                                    $c--
                                } Else {
                                    Write-Host "[Error]`t Illegal Move!! Try again.`n"
                                    Break
                                } 
                            }
                        }
                    } Else {
                        for($r=$DesiredRow; $r -lt $CurrentRow; $r++) {
                            If ($board[$r,$c] -eq $Empty) {
                                $c++
                                $i++
                            } Else {
                                If ($Attack) {
                                    $c++
                                } Else {
                                    Write-Host "[Error]`t Illegal Move!! Try again.`n"
                                    Break
                                } 
                            }
                        }
                    }
                }
                If ($Attack) {$i++}
                If ($MoveX -eq $i) {$MoveSuccess =$true}
                
            } Else {
                Write-Host "[Error]`t Illegal Move!! Try again.`n"
                Break
            }
        }

    }

    If($MoveSuccess) {
         If ($Attack) {
            $board[$DesiredRow,$DesiredColumn].Alive = $false
        }
        
        $board[$CurrentRow,$CurrentColumn] = $Empty
        $pc.CurrentPosition = $dest
        $pc.CurrentRow = $DesiredRow
        $pc.CurrentColumn = $DesiredColumn 
        
        $Player1Turn = (!($Player1Turn))           
    }
    Draw-Board
}


Function Get-Row {
    Param ([String]$Row)
    switch ($Row) {
        "A" {Return "0"}
        "B" {Return "1"}
        "C" {Return "2"}
        "D" {Return "3"}
        "E" {Return "4"}
        "F" {Return "5"}
        "G" {Return "6"}
        "H" {Return "7"}
    }
}

###########################
#endregion: Functions
####################################################


####################################################
#region: Classes
###########################

#Gives all classes that inherit(:) this class the base properties
Class ChessPiece {
    [Boolean]$Alive=$true;
    [String]$Icon;
    [String]$Color;
    [String]$StartingPosition;
    [Int]$StartingRow;
    [Int]$StartingColumn;
    [String]$CurrentPosition;
    [ValidateRange(0,8)][Int]$CurrentRow;
    [ValidateRange(0,8)][Int]$CurrentColumn;

}

Class Pawn : ChessPiece {
    #Constructer- Tells powershell what to do when you create a new Pawn and pass a string to it
    Pawn([String]$Position) {
        $this.StartingPosition = $Position
        $this.StartingRow = Get-Row $Position[0]
        $this.StartingColumn = $Position[1].ToString() - 1
        $this.CurrentPosition = $Position
        $this.CurrentRow = Get-Row $Position[0]
        $this.CurrentColumn = $Position[1].ToString() - 1

        If ($Position[0] -eq 'B') {
            $this.Icon = '♙'
            $this.Color = 'White'
        } ElseIf ($Position[0] -eq 'G') {
            $this.Icon = '♟'
            $this.Color = 'Black'
        }
    }
}

Class Rook : ChessPiece {
    Rook([String]$Position) {
        $this.StartingPosition = $Position
        $this.StartingRow = Get-Row $Position[0]
        $this.StartingColumn = $Position[1].ToString() - 1
        $this.CurrentPosition = $Position
        $this.CurrentRow = Get-Row $Position[0]
        $this.CurrentColumn = $Position[1].ToString() - 1

        If ($Position[0] -eq 'A') {
            $this.Icon = '♖'
            $this.Color = 'White'
        } ElseIf ($Position[0] -eq 'H') {
            $this.Icon = '♜'
            $this.Color = 'Black'
        }
    }
}

Class Knight : ChessPiece {
    Knight([String]$Position) {
        $this.StartingPosition = $Position
        $this.StartingRow = Get-Row $Position[0]
        $this.StartingColumn = $Position[1].ToString() - 1
        $this.CurrentPosition = $Position
        $this.CurrentRow = Get-Row $Position[0]
        $this.CurrentColumn = $Position[1].ToString() - 1

        If ($Position[0] -eq 'A') {
            $this.Icon = '♘'
            $this.Color = 'White'
        } ElseIf ($Position[0] -eq 'H') {
            $this.Icon = '♞'
            $this.Color = 'Black'
        }
    }
}

Class Bishop : ChessPiece {
    Bishop([String]$Position) {
        $this.StartingPosition = $Position
        $this.StartingRow = Get-Row $Position[0]
        $this.StartingColumn = $Position[1].ToString() - 1
        $this.CurrentPosition = $Position
        $this.CurrentRow = Get-Row $Position[0]
        $this.CurrentColumn = $Position[1].ToString() - 1

        If ($Position[0] -eq 'A') {
            $this.Icon = '♗'
            $this.Color = 'White'
        } ElseIf ($Position[0] -eq 'H') {
            $this.Icon = '♝'
            $this.Color = 'Black'
        }
    }
}

Class Queen : ChessPiece {
    Queen([String]$Position) {
        $this.StartingPosition = $Position
        $this.StartingRow = Get-Row $Position[0]
        $this.StartingColumn = $Position[1].ToString() - 1
        $this.CurrentPosition = $Position
        $this.CurrentRow = Get-Row $Position[0]
        $this.CurrentColumn = $Position[1].ToString() - 1

        If ($Position[0] -eq 'A') {
            $this.Icon = '♕'
            $this.Color = 'White'
        } ElseIf ($Position[0] -eq 'H') {
            $this.Icon = '♛'
            $this.Color = 'Black'
        }
    }
}

Class King : ChessPiece {
	King([String]$Position) {
        $this.StartingPosition = $Position
        $this.StartingRow = Get-Row $Position[0]
        $this.StartingColumn = $Position[1].ToString() - 1
        $this.CurrentPosition = $Position
        $this.CurrentRow = Get-Row $Position[0]
        $this.CurrentColumn = $Position[1].ToString() - 1

        If ($Position[0] -eq 'A') {
            $this.Icon = '♔'
            $this.Color = 'White'
        } ElseIf ($Position[0] -eq 'H') {
            $this.Icon = '♚'
            $this.Color = 'Black'
        }
    }
}

Class Blank {
    [String]$Icon='     '
}

###########################
#endregion: Classes
####################################################

$WhtPwn1 = [Pawn]::New('B1');$WhtPwn2 = [Pawn]::New('B2');$WhtPwn3 = [Pawn]::New('B3');$WhtPwn4 = [Pawn]::New('B4');
$WhtPwn5 = [Pawn]::New('B5');$WhtPwn6 = [Pawn]::New('B6');$WhtPwn7 = [Pawn]::New('B7');$WhtPwn8 = [Pawn]::New('B8');
$WhtRk1 = [Rook]::New('A1');$WhtRk2 = [Rook]::New('A8');$whtKnght1 = [Knight]::New('A2');$whtKnght2 = [Knight]::New('A7');
$WhtBshp1 = [Bishop]::New('A3');$WhtBshp2 = [Bishop]::New('A6');$WhtQn = [Queen]::New('A4');$WhtKng = [King]::New('A5')

$BlkPwn1 = [Pawn]::New('G1');$BlkPwn2 = [Pawn]::New('G2');$BlkPwn3 = [Pawn]::New('G3');$BlkPwn4 = [Pawn]::New('G4');
$BlkPwn5 = [Pawn]::New('G5');$BlkPwn6 = [Pawn]::New('G6');$BlkPwn7 = [Pawn]::New('G7');$BlkPwn8 = [Pawn]::New('G8');
$BlkRk1 = [Rook]::New('H1');$BlkRk2 = [Rook]::New('H8');$BlkKnght1 = [Knight]::New('H2');$BlkKnght2 = [Knight]::New('H7');
$BlkBshp1 = [Bishop]::New('H3');$BlkBshp2 = [Bishop]::New('H6');$BlkQn = [Queen]::New('H4');$BlkKng = [King]::New('H5')

$Empty = [Blank]::New()

[Array] $Script:WhitePieces = @(
    $WhtPwn1,$WhtPwn2,$WhtPwn3,$WhtPwn4,
    $WhtPwn5,$WhtPwn6,$WhtPwn7,$WhtPwn8,
    $WhtRk1,$WhtRk2,$whtKnght1,$whtKnght2,
    $WhtBshp1,$WhtBshp2,$WhtQn,$WhtKng
)

[Array] $Script:BlackPieces = @(
    $BlkPwn1,$BlkPwn2,$BlkPwn3,$BlkPwn4,
    $BlkPwn5,$BlkPwn6,$BlkPwn7,$BlkPwn8,
    $BlkRk1,$BlkRk2,$BlkKnght1,$BlkKnght2,
    $BlkBshp1,$BlkBshp2,$BlkQn,$BlkKng
)


Draw-Board

#$Script:Host.PrivateData.FontSize = 9