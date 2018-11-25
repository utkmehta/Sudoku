//
//  SudokuViewController.swift
//  Sudoku
//
//  Created by Utkarsh Mehta on 8/3/18.
//  Copyright © 2018 Sudoku. All rights reserved.
//

import UIKit
import Darwin

class SudokuViewController: UIViewController {
    
    class sudoku_generator {
        init() {
            self.sudoku_str = Array(repeating: 0, count: 81)
            self.final_ans = Array(repeating: 0, count: 0)
        }
        
        func unUsedInBox(row: Int, col: Int, number: Int) -> Bool {
            for i in 0..<3 {
                for j in 0..<3 {
                    if(sudoku_str[(row + i) * 9 + (col + j)] == number) {
                        return false;
                    }
                }
            }
            return true;
        }
        
        func unUsedInRow(row: Int, number: Int) -> Bool {
            for j in 0..<9 {
                if(sudoku_str[row * 9 + j] == number) {
                    return false;
                }
            }
            return true;
        }
        
        func unUsedInCol(col: Int, number: Int) -> Bool {
            for i in 0..<9 {
                if(sudoku_str[i * 9 + col] == number) {
                    return false;
                }
            }
            return true;
        }
        
        func generate_random_board() {
            var i = 0;
            while (i < 81) {
                var temp = true
                var count = 0
                var num = 0;
                repeat {
                    if(count >= 15) {
                        temp = false
                        break
                    }
                    num = Int(arc4random_uniform(UInt32(9)) + 1)
                    count = count + 1
                }
                while(!unUsedInRow(row: i / 9, number: num)
                    || !unUsedInCol(col: i - ((i / 9) * 9), number: num)
                    || !unUsedInBox(row: (i / 9) - ((i / 9) % 3), col: i - ((i / 9) * 9) - ((i - ((i / 9) * 9)) % 3), number: num))
                if(!temp) {
                    sudoku_str[i] = 0
                    i = i - 1
                }
                else {
                    sudoku_str[i] = num
                    i = i + 1
                }
            }
        }
        
        // Backtracking algorithm
        func solution_exists_helper(sudoku: inout [Int], index: Int) -> Bool {
            let i = sudoku[index]
            if(unUsedInRow(row: index / 9, number: i) && unUsedInCol(col: index - ((index / 9) * 9), number: i) && unUsedInBox(row: index / 9 - ((index / 9) % 3), col: index - ((index / 9) * 9) - ((index - ((index / 9) * 9)) % 3), number: i)) {
                var temp = true
                for j in 0..<81 {
                    if(sudoku[j] == 0) {
                        
                        temp = false
                    }
                }
                if(temp) {
                    return true
                }
            }
            for k in (index + 1)..<81 {
                if(sudoku[k] == 0) {
                    for j in 1..<10 {
                        sudoku[k] = j
                        return solution_exists_helper(sudoku: &sudoku, index: k)
                    }
                }
            }
            return false
        }
        
        func solution_exists(index: Int, num: Int) -> Bool {
            var sudoku_temp = sudoku_str
            sudoku_temp[index] = num
            return solution_exists_helper(sudoku: &sudoku_temp, index: 0)
        }
        
        func can_dig_hole(index: Int) -> Bool {
            for i in 1..<10 {
                if(i != sudoku_str[index] && unUsedInRow(row: index / 9, number: i) && unUsedInCol(col: index - ((index / 9) * 9), number: i) && unUsedInBox(row: index / 9 - ((index / 9) % 3), col: index - ((index / 9) * 9) - ((index - ((index / 9) * 9)) % 3), number: i)) {
                    if(solution_exists(index: index, num: i)) {
                        return false
                    }
                }
            }
            return true
        }
        
        func randomize_remove() {
            // Extremely easy:- 55 clues
            
            // Pruning technique
            var temp = Array(repeating: true, count: 81)
            var i = 0
            var num = 0
            while(i < 10) {
                num = Int(arc4random_uniform(UInt32(80)))
                if(temp[num] && can_dig_hole(index: num)) {
                    sudoku_str[num] = 0
                    i = i + 1
                }
                else {
                    temp[num] = false
                }
            }
        }
        
        func process() -> Array<Int> {
            generate_random_board()
            final_ans = sudoku_str
            randomize_remove()
            return sudoku_str
        }
        
        func return_final() -> Array<Int> {
            return final_ans
        }
        var sudoku_str: [Int]
        var final_ans: [Int]
    }
    
    var final_ans: [Int] = Array(repeating: 0, count: 0)
    
    @IBAction func test(_ sender: UITextField) {
        if(sender.text! == String(1)) {
            print ("YES")
        }
        else {
            print("NO")
        }
    }
    
    @IBOutlet weak var label: UILabel!
    @IBAction func submitButton(_ sender: Any) {
        var temp = true
        for i in 0..<81 {
            if(grid[i].text == "") {
                label.text = "Board not complete"
                temp = false
                break;
            }
            if(grid[i].text != String(final_ans[i])) {
                label.text = "Wrong solution"
                temp = false
                break;
            }
        }
        if(temp) {
            label.text = "Correct solution!"
        }
    }
    @IBOutlet var grid: [UITextField]!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//        for i in 0..<81 {
//            Number pad instead of keyboard
//            grid[i].keyboardType = UIKeyboardType.numberPad
//        }
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem:
            UIBarButtonItem.SystemItem.done, target: self, action: #selector(doneClicked))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil)
        
        toolbar.setItems([flexibleSpace, doneButton], animated: true)
        for i in 0..<81 {
            grid[i].inputAccessoryView = toolbar
        }
        
        let sudoku = sudoku_generator()
        let sudoku_str = sudoku.process()
        final_ans = sudoku.return_final()
        for i in 0..<sudoku_str.count {
            if(sudoku_str[i] != 0) {
                grid[i].text = String(sudoku_str[i])
            }
        }
        
    }
    
    @objc func doneClicked() {
        view.endEditing(true)
    }
    
    // Resigning first responder
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
