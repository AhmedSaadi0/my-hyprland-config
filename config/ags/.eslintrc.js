module.exports = {
    root: true,
    env: {
        browser: true,
        es2021: true,
        node: true,
    },
    extends: ['eslint:recommended', 'plugin:@typescript-eslint/recommended'],
    parser: '@typescript-eslint/parser',
    parserOptions: {
        ecmaVersion: 'latest',
        sourceType: 'module',
        project: './tsconfig.json',
        tsconfigRootDir: '.',
    },
    plugins: ['@typescript-eslint', 'import'],
    rules: {
        '@typescript-eslint/no-explicit-any': 'warn',
        '@typescript-eslint/explicit-function-return-type': 'error',
        '@typescript-eslint/no-unused-vars': [
            'warn',
            {
                argsIgnorePattern: '^_',
                varsIgnorePattern: '^_',
                caughtErrorsIgnorePattern: '^_',
            },
        ],
        'import/no-unresolved': 'error',
        'no-console': 'warn',
        semi: ['error', 'always'],
        quotes: ['error', 'single', { avoidEscape: true }],
    },
    settings: {
        'import/resolver': {
            typescript: {
                alwaysTryTypes: true,
            },
        },
    },
    overrides: [
        {
            files: ['*.ts', '*.tsx'],
            rules: {
                '@typescript-eslint/explicit-function-return-type': ['error'],
            },
        },
        {
            files: ['.eslintrc.*', '*.config.*'],
            parserOptions: {
                sourceType: 'script',
            },
        },
    ],
};
