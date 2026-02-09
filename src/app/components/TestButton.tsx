import React from 'react';

interface TestButtonProps {
  label?: string;
  onClick?: () => void;
}

/**
 * TestButton - Componente de prueba para validar auto-merge
 */
export default function TestButton({ 
  label = 'Test Auto-Merge', 
  onClick 
}: TestButtonProps) {
  const handleClick = () => {
    console.log('🎉 Auto-merge test button clicked!');
    onClick?.();
  };

  return (
    <button
      onClick={handleClick}
      className="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600"
    >
      {label}
    </button>
  );
}
