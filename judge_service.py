import os
import sys
import subprocess
import tempfile
import time
import re

GPP_PATH = "g++"

def run_custom_code(source_code, input_data="", language="C++", timeout=2.5):
    """
    Biên dịch và chạy thử code với custom input (chưa chấm điểm).
    """
    if not source_code or len(source_code.strip()) == 0:
        return {
            'status': 'Compile Error',
            'output': '',
            'error': 'Mã nguồn rỗng! Vui lòng viết code trước khi chạy thử.',
            'execution_time': 0
        }

    with tempfile.TemporaryDirectory() as tmpdir:
        src_file = os.path.join(tmpdir, "solution.cpp")
        exe_file = os.path.join(tmpdir, "solution.exe")

        with open(src_file, "w", encoding="utf-8") as f:
            f.write(source_code)

        # 1. Biên dịch tối ưu tốc độ (-O0)
        compile_cmd = [GPP_PATH, "-O0", "-std=c++17", src_file, "-o", exe_file]
        try:
            compile_proc = subprocess.run(
                compile_cmd,
                capture_output=True,
                text=True,
                encoding="utf-8",
                errors="replace",
                timeout=25.0
            )
            if compile_proc.returncode != 0:
                return {
                    'status': 'Compile Error',
                    'output': '',
                    'error': compile_proc.stderr or compile_proc.stdout,
                    'execution_time': 0
                }
        except subprocess.TimeoutExpired:
            return {
                'status': 'Compile Error',
                'output': '',
                'error': 'Quá thời gian biên dịch (vượt quá 25 giây).',
                'execution_time': 0
            }
        except Exception as e:
            return {
                'status': 'Compile Error',
                'output': '',
                'error': f'Lỗi hệ thống biên dịch: {str(e)}',
                'execution_time': 0
            }

        # 2. Chạy thử nghiệm
        start_time = time.time()
        try:
            run_proc = subprocess.run(
                [exe_file],
                input=input_data,
                capture_output=True,
                text=True,
                encoding="utf-8",
                errors="replace",
                timeout=timeout
            )
            exec_time = round(time.time() - start_time, 3)

            if run_proc.returncode != 0:
                return {
                    'status': 'Runtime Error',
                    'output': run_proc.stdout,
                    'error': run_proc.stderr if run_proc.stderr else f'Chương trình thoát với mã lỗi: {run_proc.returncode}',
                    'execution_time': exec_time
                }

            return {
                'status': 'Success',
                'output': run_proc.stdout,
                'error': '',
                'execution_time': exec_time
            }

        except subprocess.TimeoutExpired:
            return {
                'status': 'Time Limit Exceeded',
                'output': '',
                'error': f'Chương trình chạy quá thời gian cho phép ({timeout}s). Kiểm tra lại vòng lặp vô tận!',
                'execution_time': timeout
            }
        except Exception as e:
            return {
                'status': 'Runtime Error',
                'output': '',
                'error': f'Lỗi khi thực thi: {str(e)}',
                'execution_time': 0
            }

def normalize_output(text):
    if not text:
        return ""
    lines = [line.rstrip() for line in text.strip().splitlines()]
    return "\n".join(lines).strip()

def judge_submission(source_code, test_cases, language="C++", time_limit=2.5, max_points=10):
    """
    Chấm điểm chính thức toàn bộ bộ test case.
    """
    if not source_code or len(source_code.strip()) == 0:
        return {
            'status': 'Compile Error',
            'score': 0,
            'passed_tests': 0,
            'total_tests': len(test_cases),
            'execution_time': 0,
            'compile_error': 'Mã nguồn rỗng! Vui lòng nộp code hợp lệ.',
            'test_details': []
        }

    # Kiểm tra xem bài tập có yêu cầu đọc dữ liệu đầu vào hay không
    needs_input = any(bool(tc.get('input_data', '').strip()) for tc in test_cases)
    if needs_input:
        input_patterns = [
            r'\b(std::)?cin\s*>>',
            r'\b(std::)?cin\s*\.',
            r'\b(std::)?getline\s*\(\s*(std::)?cin',
            r'\bscanf\s*\(',
            r'\bgetchar\s*\(',
            r'\bgetc\s*\(\s*stdin\s*\)',
            r'\bfgetc\s*\(\s*stdin\s*\)',
            r'\bfgets\s*\(.*stdin\s*\)',
            r'\bread\s*\('
        ]
        has_input_read = any(re.search(pat, source_code) for pat in input_patterns)
        if not has_input_read:
            return {
                'status': 'Wrong Answer',
                'score': 0.0,
                'passed_tests': 0,
                'total_tests': len(test_cases),
                'execution_time': 0.0,
                'compile_error': '',
                'test_details': [
                    {
                        'test_index': idx,
                        'is_hidden': bool(tc.get('is_hidden', 0)),
                        'points': tc.get('points', 2),
                        'status': 'Wrong Answer',
                        'execution_time': 0.0,
                        'input': tc.get('input_data', ''),
                        'expected': normalize_output(tc.get('expected_output', '')),
                        'actual': '',
                        'error': "Chương trình chưa có lệnh đọc dữ liệu đầu vào (thiếu 'cin >>' hoặc 'scanf'). Vui lòng nhập dữ liệu từ bàn phím theo yêu cầu đề bài!"
                    }
                    for idx, tc in enumerate(test_cases, 1)
                ]
            }

    with tempfile.TemporaryDirectory() as tmpdir:
        src_file = os.path.join(tmpdir, "submission.cpp")
        exe_file = os.path.join(tmpdir, "submission.exe")

        with open(src_file, "w", encoding="utf-8") as f:
            f.write(source_code)

        # 1. Biên dịch tối ưu tốc độ (-O0)
        compile_cmd = [GPP_PATH, "-O0", "-std=c++17", src_file, "-o", exe_file]
        try:
            compile_proc = subprocess.run(
                compile_cmd,
                capture_output=True,
                text=True,
                encoding="utf-8",
                errors="replace",
                timeout=20.0
            )
            if compile_proc.returncode != 0:
                err_msg = compile_proc.stderr or compile_proc.stdout
                return {
                    'status': 'Compile Error',
                    'score': 0,
                    'passed_tests': 0,
                    'total_tests': len(test_cases),
                    'execution_time': 0,
                    'compile_error': err_msg,
                    'test_details': []
                }
        except subprocess.TimeoutExpired:
            return {
                'status': 'Compile Error',
                'score': 0,
                'passed_tests': 0,
                'total_tests': len(test_cases),
                'execution_time': 0,
                'compile_error': 'Quá thời gian biên dịch (vượt quá 20 giây).',
                'test_details': []
            }
        except Exception as e:
            return {
                'status': 'Compile Error',
                'score': 0,
                'passed_tests': 0,
                'total_tests': len(test_cases),
                'execution_time': 0,
                'compile_error': f'Lỗi hệ thống biên dịch: {str(e)}',
                'test_details': []
            }

        # 2. Chấm từng test case
        total_tests = len(test_cases)
        passed_tests = 0
        total_earned_score = 0.0
        max_possible_points = sum(tc.get('points', 2) for tc in test_cases) or 1
        max_exec_time = 0.0
        overall_status = 'Accepted'
        test_details = []

        for idx, tc in enumerate(test_cases, 1):
            tc_input = tc['input_data']
            tc_expected = normalize_output(tc['expected_output'])
            tc_weight = tc.get('points', 2)
            is_hidden = bool(tc.get('is_hidden', 0))

            start_t = time.time()
            tc_result = {
                'test_index': idx,
                'is_hidden': is_hidden,
                'points': tc_weight,
                'status': 'Passed',
                'execution_time': 0,
                'input': tc_input,
                'expected': tc_expected,
                'actual': '',
                'error': ''
            }

            try:
                run_proc = subprocess.run(
                    [exe_file],
                    input=tc_input,
                    capture_output=True,
                    text=True,
                    encoding="utf-8",
                    errors="replace",
                    timeout=time_limit
                )
                duration = round(time.time() - start_t, 3)
                tc_result['execution_time'] = duration
                if duration > max_exec_time:
                    max_exec_time = duration

                if run_proc.returncode != 0:
                    tc_result['status'] = 'Runtime Error'
                    tc_result['error'] = 'Chương trình gặp lỗi khi chạy (Runtime Error).'
                    if overall_status == 'Accepted':
                        overall_status = 'Runtime Error'
                else:
                    actual_out = normalize_output(run_proc.stdout)
                    tc_result['actual'] = actual_out

                    if actual_out == tc_expected:
                        tc_result['status'] = 'Passed'
                        passed_tests += 1
                        total_earned_score += tc_weight
                    else:
                        tc_result['status'] = 'Wrong Answer'
                        if overall_status == 'Accepted':
                            overall_status = 'Wrong Answer'

            except subprocess.TimeoutExpired:
                tc_result['status'] = 'Time Limit Exceeded'
                tc_result['execution_time'] = time_limit
                tc_result['error'] = f'Vượt quá giới hạn thời gian {time_limit}s'
                if overall_status == 'Accepted':
                    overall_status = 'Time Limit Exceeded'
            except Exception as e:
                tc_result['status'] = 'Runtime Error'
                tc_result['error'] = str(e)
                if overall_status == 'Accepted':
                    overall_status = 'Runtime Error'

            test_details.append(tc_result)

        # Điểm số quy đổi
        final_score = round((total_earned_score / max_possible_points) * max_points, 1)

        return {
            'status': overall_status,
            'score': final_score,
            'passed_tests': passed_tests,
            'total_tests': total_tests,
            'execution_time': max_exec_time,
            'compile_error': '',
            'test_details': test_details
        }
