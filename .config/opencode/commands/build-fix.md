Fix build errors with minimal changes. Delegate to the debugger agent for root-cause analysis if the fix is not obvious.

1. Run the build command and capture the error output.
2. Identify the root cause of the build failure.
3. Apply the minimal fix that resolves the error.
4. Re-run the build to verify the fix.
5. If the build still fails after 3 attempts, delegate to `debugger-glm-5.2` for root-cause analysis.

$ARGUMENTS
