#include <iostream>
#include <cstdlib>
#include <iomanip>
using namespace std;

//Create a 9x9 Sudoku board
char board[9][9];

void printBoard ()
{
	for(int i = 0; i < 9; i++)
	{
		if (i % 3 == 0)
			cout << "+---+---+---+" << endl;
		for(int j = 0; j < 9; j++)
		{
			if(j % 3 == 0)
				cout << "|";
			cout << board[i][j];
		}
		cout << "|" << endl;
	}
	cout << "+---+---+---+" << endl;
}

//Check each row with brutte force
bool checkRow (int i)
{
	for(int j = 0; j < 8; j++)
	{
		if(board [i][j] != ' ')
		{
			for(int k = j + 1; k < 9; k++)
			{
				if(board [i][j] == board[i][k])
					return false;
			}
		}
	}
	return true;
}

//Check each collumn with brutte force
bool checkCol (int j)
{
	for(int i = 0; i < 8; i++)
	{
		if(board [i][j] != ' ')
		{
			for(int k = i + 1; k < 9; k++)
			{
				if(board [i][j] == board[k][j])
					return false;
			}
		}
	}
	return true;
}

//Check 3x3 box to make sure rules don't fail
bool checkBox (int i, int j)
{
	int boxRow = (i / 3) * 3;
	int boxCol = (j / 3) * 3;
	
	for(int k = 0; k < 8; k++)
	{
		int ki = boxRow + (k / 3);
		int kj = boxCol + (k % 3);
		
		if(board [ki][kj] != ' ')
		{
			for(int l = k + 1; l < 8; l++)
			{
				int li = boxRow + (l / 3);
				int lj = boxCol + (l % 3);
				
				if(board [ki][kj] == board [li][lj])
				{
					return false;
				}
			}
		}
	}

	return true;
}

bool solveBoard (int i, int j)
{
	if(checkRow(i) == false) return false;
	if(checkCol(j) == false) return false;	
	if(checkBox(i, j) == false) return false;

// Make guesses in the row	
	for(int k = 0; k < 9; k++)
	{
		if(board [i][k] == ' ')
		{
			for(char guess = '1'; guess <= '9'; guess++)
			{
				board [i][k] = guess;
				if(solveBoard(i,k) == true) break;
				board[i][k] = ' ';
				if(guess == '9') return false;
			}
		}
	}	

//Make guesses in the column
	for(int k = 0; k < 9; k++)
	{
		if(board [k][j] == ' ')
		{
			for(char guess = '1'; guess <= '9'; guess++)
			{
				board [k][j] = guess;
				if(solveBoard(k,j) == true) break;
				board[k][j] = ' ';
				if(guess == '9') return false;
			}
		}
	}
	//printBoard ();
	return true;
}


//Input a board using dashes as blank spaces
//Enter numbers and blank spaces starting from top left and work to bottom right
int main () 
{
	
	char line[11];
	
	cout << "Input a board:" << endl;
	
	for(int i = 0; i < 9; i++)
	{
		cin >> line;
		int length = strlen (line);
	
		for(int j = 0; j < length; j++)
		{
			board[i][j] = line [j];
			
			if(board [i][j] < '1' || board[i][j] > '9')
			{
				board[i][j] = ' ';
			}
		
		}
	}

	printBoard ();
	solveBoard (0,0);
	printBoard ();





	    return EXIT_SUCCESS;
}
